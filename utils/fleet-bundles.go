package main

import (
	"flag"
	"log"
	"os"
	"os/exec"
	"path/filepath"
)

func main() {
	path := flag.String("path", "", "The path to search for symbolic links")
	flag.Parse()

	if *path == "" {
		log.Println("You must provide a path to search for symbolic links")
		os.Exit(1)
	}

	// recursively find fleet.yaml files
	fleets, err := findFileDirs(*path, "fleet.yaml")
	if err != nil {
		log.Fatal("Error:", err)
	}

	log.Println("Found", len(fleets), "fleet bundles")

	// convert paths to absolute paths
	for i, fleet := range fleets {
		absPath, err := filepath.Abs(fleet)
		if err != nil {
			log.Fatal("Error:", err)
		}
		fleets[i] = absPath
	}

	lintErrors := 0

	// for each fleet.yaml file, run fleet test
	for _, fleet := range fleets {
		log.Println("Linting", fleet)

		// cd to fleet dir
		err := os.Chdir(fleet)
		if err != nil {
			log.Fatal("Error:", err)
		}

		// use fleet apply to attempt to bundle a bundle
		cmd := exec.Command("fleet", "apply", "foo", ".", "-o", "/dev/null")
		_, err = cmd.CombinedOutput()
		if err != nil {
			log.Println("Error:", err)
			lintErrors++
		}
	}

	// report total number of errors
	log.Println("Total errors:", lintErrors)
	if lintErrors > 0 {
		os.Exit(1)
	}
}

func findFileDirs(path string, filename string) ([]string, error) {
	fleets := []string{}

	err := filepath.Walk(path, func(path string, info os.FileInfo, err error) error {
		if err != nil {
			return err
		}
		// skip directories
		if info.IsDir() {
			return nil
		}
		// check if file is X
		if info.Name() == filename {
			// then asssume that this is a X directory
			dir := filepath.Dir(path)
			fleets = append(fleets, dir)
		}
		return nil
	})
	return fleets, err
}
