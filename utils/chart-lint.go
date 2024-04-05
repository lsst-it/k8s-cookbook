package main

import (
	"fmt"
	"log"
	"os"
	"os/exec"
	"path/filepath"
)

func main() {
	// recursively find Chart.yaml files
	charts, err := findChartDirs(".")
	if err != nil {
		fmt.Println("Error:", err)
		log.Fatal(err)
	}

	fmt.Println("Found", len(charts), "charts")

	// convert chart paths to absolute paths
	for i, chart := range charts {
		absPath, err := filepath.Abs(chart)
		if err != nil {
			fmt.Println("Error:", err)
			log.Fatal(err)
		}
		charts[i] = absPath
	}

	chartErrors := 0

	// for each Chart.yaml file, run helm lint
	for _, chart := range charts {
		fmt.Println("Linting", chart)

		// cd to chart dir
		err := os.Chdir(chart)
		if err != nil {
			fmt.Println("Error:", err)
			log.Fatal(err)
		}

		// run helm lint
		cmd := exec.Command("helm", "lint")
		out, err := cmd.CombinedOutput()
		if err != nil {
			fmt.Println("Error:", string(out))
			chartErrors++
			continue
		}
	}

	// report total number of errors
	fmt.Println("Total errors:", chartErrors)
	if chartErrors > 0 {
		os.Exit(1)
	}
}

func findChartDirs(path string) ([]string, error) {
	charts := []string{}

	err := filepath.Walk(path, func(path string, info os.FileInfo, err error) error {
		if err != nil {
			return err
		}
		// skip directories
		if info.IsDir() {
			return nil
		}
		// check if file is Chart.yaml
		if info.Name() == "Chart.yaml" {
			// then asssume that this is a chart directory
			dir := filepath.Dir(path)
			charts = append(charts, dir)
		}
		return nil
	})
	return charts, err
}
