# Markclip - Atom package

An Atom package to insert image form clipboard into markdown file.

## Usage

Copy some image into clipboard and key `cmd-v` (Mac) or `ctrl-v` (Windows) in markdown file.

## Config

### saveType

- **base64**

Insert base64 string like

```
![](data:image/png;base64,...)
```

- **file**

Create an image file in the same directory of your markdown file, then insert into markdown with a md5 file name.

```
path
├── markdown-file-name.md
├── image-md5-name.png
└── ...
```

```
![](image-md5-name.png)
```

- **file in folder**

Create a directory with the same name of the current markdown file. Put the image in the directory, then insert into markdown with a md5 file name.

```
path
├── markdown-file-name.md
├── markdown-file-name
│   ├── image-md5-name.png
│   └── ...
└── ...
```

```
![](markdown-file-name/image-md5-name.png)
```

### folderSpaceReplacer

Replace spaces to special charset in image folder name while using setting `saveType: file in folder`. Default to `-`.
