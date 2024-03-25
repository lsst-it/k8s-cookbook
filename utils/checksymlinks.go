package main

import (
	"flag"
	"fmt"
	"os"
	"path/filepath"
)

func main() {
	path := flag.String("path", "", "The path to search for symbolic links")
	flag.Parse()

	if *path == "" {
		fmt.Println("You must provide a path to search for symbolic links")
		os.Exit(1)
	}

	errors := 0

	// walk through the file system looking for symbolic links
	links := []string{}
	findSymlinks(*path, &links)

	// inspect symlinks
	for _, link := range links {
		// Get the target of the symbolic link
		target, err := os.Readlink(link)
		if err != nil {
			fmt.Println("Error:", err)
			continue
		}

		// check the link target to see if it ends with a / or not
		if target[len(target)-1] == '/' {
			fmt.Println(link, "=>", target, "ends with a /")
			errors++
		}

		// turn the relative target into an absolute path
		var absTarget string
		if target[0] != '/' {
			absTarget = filepath.Join(filepath.Dir(link), target)
		}

		// check if the target exists
		var s os.FileInfo
		if s, err = os.Stat(absTarget); err != nil {
			fmt.Println(link, "=>", target, "does not exist")
			errors++
			continue
		}

		// check if the target is a dir
		if !s.IsDir() {
			fmt.Println(link, "=>", target, "is not a directory")
			errors++
		}

		// check if the parent dir of the target is a a dir named "lib"
		parentDir := filepath.Dir(absTarget)
		if filepath.Base(parentDir) != "lib" {
			fmt.Println(link, "=>", target, "is not in a directory named lib")
			errors++
		}
	}

	// exit with a non-zero status if there were any errors
	if errors > 0 {
		fmt.Println("Found", errors, "symbolic links with errors")
		os.Exit(1)
	}
}

func findSymlinks(dir string, links *[]string) {
	// Walk through the directory and its subdirectories
	filepath.Walk(dir, func(path string, info os.FileInfo, err error) error {
		if err != nil {
			fmt.Println("Error:", err)
			return nil
		}
		// Check if the file is a symbolic link
		if info.Mode()&os.ModeSymlink != 0 {
			// If it is, add it to the links slice
			*links = append(*links, path)
		}
		return nil
	})
}
