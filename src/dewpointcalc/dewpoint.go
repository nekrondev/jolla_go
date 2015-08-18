package main

import (
	"encoding/json"
	"errors"
	"fmt"
	"gopkg.in/qml.v1"
	"math"
	"os"
	"runtime"
	"time"
)

const VERSION = "0.1.1"

var (
	config Config
)

type DewpointControl struct {
	Root         qml.Object
	Dewpoint     string
	Humidity     string
	Temperature  string
	Lastcalctime time.Time
	temp         float64
	humidity     float64
	UnitIndex    int
}

type Config struct {
	TempOnClose float64
	HumOnClose  float64
	UnitIndex   int
	LastRun     time.Time
}

func main() {
	if err := qml.Run(run); err != nil {
		fmt.Fprintf(os.Stderr, "error: %v\n", err)
		os.Exit(1)
	}
}

func getPath() (string, error) {
	path := os.Getenv("XDG_CONFIG_HOME")
	if len(path) == 0 {
		path = os.Getenv("HOME")
		if len(path) == 0 {
			return "", errors.New("No XDG_CONFIG or HOME env set!")
		}
	}
	return path, nil
}

// Load JSON serialized config data
func loadSettings() error {
	path, err := getPath()
	if err != nil {
		panic(err)
	}
	filename := fmt.Sprintf("%s/.config/harbour-dewpointcalc/settings_%s.json", path, VERSION)
	fmt.Printf("Trying to load settings from %s\n", filename)
	f, err := os.Open(filename)
	if err != nil {
		config = Config{TempOnClose: 21.0, HumOnClose: 50.0, LastRun: time.Now(), UnitIndex: 0}
		return nil
	}
	defer f.Close()
	jsondec := json.NewDecoder(f)
	err = jsondec.Decode(&config)
	if err != nil {
		return err
	}
	return nil
}

// Save serialized config data as JSON
func saveSettings() error {
	path, err := getPath()
	if err != nil {
		panic(err)
	}

	directory := fmt.Sprintf("%s/.config/harbour-dewpointcalc", path)
	if _, err := os.Stat(directory); os.IsNotExist(err) {
		os.MkdirAll(directory, 0777)
	}
	filename := fmt.Sprintf("%s/settings_%s.json", directory, VERSION)
	f, err := os.Create(filename)
	if err != nil {
		fmt.Printf("Can not create settings: %v\n", err)
		return errors.New("Can not create settings file!")
	}
	defer f.Close()

	jsondata, err := json.MarshalIndent(config, "", "  ")
	if err != nil {
		fmt.Println("Can not marshal to json")
		return errors.New("Can not marshal to json!")
	}
	f.Write(jsondata)
	return nil
}

func run() error {
	err := loadSettings()
	if err != nil {
		fmt.Printf("Error %s, stopping execution.", err)
		os.Exit(-2)
	}
	// Set values back to sliders
	dewpoint := DewpointControl{Dewpoint: "", Humidity: "", Temperature: "", UnitIndex: config.UnitIndex}
	//dewpoint.Root.ObjectByName("tempslider").Set("value", config.TempOnClose)
	//dewpoint.Root.ObjectByName("humidityslider").Set("value", config.HumOnClose)
	dewpoint.Lastcalctime = config.LastRun

	engine := qml.NewEngine()
	engine.Translator("/usr/share/harbour-dewpointcalc/qml/i18n")

	//dewpoint := DewpointControl{Dewpoint: "", Humidity: "", Temperature: ""}
	context := engine.Context()
	context.SetVar("dewpointctrl", &dewpoint)
	controls, err := engine.LoadFile("/usr/share/harbour-dewpointcalc/qml/main.qml")
	if err != nil {
		return err
	}

	window := controls.CreateWindow(nil)
	dewpoint.Root = window.Root()

	err = loadSettings()
	if err != nil {
		fmt.Printf("Error %s, stopping execution.", err)
		os.Exit(-2)
	}
	// Set values back to sliders
	if config.UnitIndex == 0 {
		dewpoint.Root.ObjectByName("tempslider").Set("minimumValue", 0)
		dewpoint.Root.ObjectByName("tempslider").Set("maximumValue", 50)
	} else {
		dewpoint.Root.ObjectByName("tempslider").Set("minimumValue", 32)
		dewpoint.Root.ObjectByName("tempslider").Set("maximumValue", 122)
	}

	dewpoint.Root.ObjectByName("tempslider").Set("value", config.TempOnClose)
	dewpoint.Root.ObjectByName("humidityslider").Set("value", config.HumOnClose)
	//dewpoint.Lastcalctime = config.LastRun
	window.Show()
	window.Wait()

	config.TempOnClose = dewpoint.temp
	config.HumOnClose = dewpoint.humidity
	config.LastRun = time.Now()
	config.UnitIndex = dewpoint.UnitIndex
	err = saveSettings()
	if err != nil {
		fmt.Println(err)
	}
	return nil
}

// Convert Celsius to Fahrenheit
func (ctrl *DewpointControl) CelsiusToFahrenheit(temp float64) float64 {
	return temp*1.8 + 32
}

// Convert Fahrenheit to Celsius
func (ctrl *DewpointControl) FahrenheitToCelsius(temp float64) float64 {
	return (temp - 32) * 5 / 9
}

// Switch temperature units based on index, i.e. 0 = Celsius, 1 = Fahrenheit
func (ctrl *DewpointControl) SwitchUnit(index int) {
	if index != ctrl.UnitIndex {
		fmt.Printf("SwitchUnit: index=%v, unitindex=%v, temp=%v\n", index, ctrl.UnitIndex, ctrl.temp)
		//ctrl.Calc(ctrl.temp, ctrl.humidity)
		if index == 0 {
			ctrl.temp = ctrl.FahrenheitToCelsius(ctrl.temp)
			ctrl.Root.ObjectByName("tempslider").Set("minimumValue", 0)
			ctrl.Root.ObjectByName("tempslider").Set("maximumValue", 50)
		} else {
			ctrl.temp = ctrl.CelsiusToFahrenheit(ctrl.temp)
			ctrl.Root.ObjectByName("tempslider").Set("minimumValue", 32)
			ctrl.Root.ObjectByName("tempslider").Set("maximumValue", 122)
		}
		fmt.Printf("SwitchUnit: Set slider to: %v\n", ctrl.temp)
		ctrl.Root.ObjectByName("tempslider").Set("value", ctrl.temp)
		fmt.Printf("SwitchUnit: Temp: %v\n", ctrl.temp)
		ctrl.UnitIndex = index
	}
}

// Calculate the dewpoint temperature ans formats it based on selected unit index
func (ctrl *DewpointControl) Calc(temp, humidity float64) string {
	fmt.Printf("Calc: %v, %v\n", temp, ctrl.UnitIndex)
	ctrl.Temperature = fmt.Sprintf("%0.1f", temp)
	ctrl.Humidity = fmt.Sprintf("%0.1f", humidity)
	ctrl.temp = temp
	//fmt.Println(ctrl.temp)
	if ctrl.UnitIndex == 1 {
		temp = ctrl.FahrenheitToCelsius(temp)
	}
	res := TD(humidity, temp)
	if ctrl.UnitIndex == 1 {
		res = ctrl.CelsiusToFahrenheit(res)
	}
	ctrl.Dewpoint = fmt.Sprintf("%0.1f", res)
	fmt.Printf("Calc: ctrl.temp %v\n", ctrl.temp)
	ctrl.humidity = humidity
	qml.Changed(ctrl, &ctrl.Temperature)
	qml.Changed(ctrl, &ctrl.Humidity)
	qml.Changed(ctrl, &ctrl.Dewpoint)
	// Update cover
	//if ctrl.Root != nil {
	//	ctrl.Root.ObjectByName("cover").Call("updateData")
	//}
	return ctrl.Dewpoint
}

// Returns the GO runtime version used for building the application
func (ctrl *DewpointControl) RuntimeVersion() string {
	return runtime.Version()
}

// Returns the dewpoint calculator application version
func (ctrl *DewpointControl) Version() string {
	return VERSION
}

// Dewpoint calculations are done here

// Calculate Staettigunsdampfdruck in hPa
func SDD(T float64) float64 {
	var a, b float64
	if T >= 0.0 {
		a = 7.5
		b = 237.3
	} else if T < 0.0 {
		a = 7.6
		b = 240.7
	}
	return 6.1078 * math.Pow(10, (a*T)/(b+T))
}

// Calculate Dampfdruck in hPa
func DD(r, T float64) float64 {
	return r / 100.0 * SDD(T)
}

// Calculate relative Luftfeuchte
func r(T, TD float64) float64 {
	return 100.0 * SDD(TD) / SDD(T)
}

// Calculate ???
func v(r, T float64) float64 {
	return math.Log10(DD(r, T) / 6.1078)
}

// Calculate Taupunkttemperatur in C
func TD(r, T float64) float64 {
	var a, b float64
	if T >= 0.0 {
		a = 7.5
		b = 237.3
	} else if T < 0.0 {
		a = 7.6
		b = 240.7
	}
	return b * v(r, T) / (a - v(r, T))
}

// Calculate absolute Feuchte in g Wasserdampf pro m3 Luft
func AF(r, TK float64) float64 {
	return math.Pow(10.0, 5*18.016/8314.3*DD(r, TK-273.15)/TK)
}
