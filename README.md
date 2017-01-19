# Markclip - Atom package

An Atom package to insert image form clipboard into markdown file.

## Usage

Copy some image into clipboard and key `cmd-v` (Mac) or `ctrl-v` (Windows) in markdown file.

## Config

### saveType

#### **base64**

Insert base64 string like

```
![](data:image/png;base64,...)
```

#### **file**

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

#### **file in folder**

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

#### **default folder**

Create a directory with the name specified in the settings (defaults to 'img'). Put the image in the directory, then insert into markdown with an md5 file name.

```
path
├── markdown-file-name.md
├── img
│   ├── image-md5-name.png
│   └── ...
└── ...
```

```
![](img/image-md5-name.png)
```

*Use Case*: having a common image directory for a collection of markdown files all in the same folder (e.g. wikis). Reduces the number of image directories compared to **file in folder**.

#### **custom file**

Ask to save each time.

### folderSpaceReplacer

Replace spaces to special charset in image folder name while using setting `saveType: file in folder`. Default to `-`.
