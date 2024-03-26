package main

import (
	"flag"
	"fmt"
	"os"
	"path/filepath"
)

func main() {
	site := flag.String("site", "", "site name")
	flag.Parse()

	if *site == "" {
		fmt.Println("Please specify the site name")
		os.Exit(1)
	}

	// site dir to start searching from
	dir := fmt.Sprintf("fleet/s/%s", *site)

	// walk through the file system looking for symbolic links
	links := []string{}
	findSymlinks(dir, &links)

	updateSymlinks(links)
}

func updateSymlinks(links []string) {
	for _, link := range links {
		target, err := os.Readlink(link)
		if err != nil {
			fmt.Println("Error:", err)
			continue
		}

		// Check if the target ends with a /
		if target[len(target)-1] == '/' {
			fmt.Println(link, "=>", target, "ends with a /")
		} else {
			continue
		}

		// remove the old symlink
		if err := os.Remove(link); err != nil {
			fmt.Println("Error:", err)
		}

		// recreate the symlink without the trailing /
		if err := os.Symlink(target[:len(target)-1], link); err != nil {
			fmt.Println("Error:", err)
		}
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
