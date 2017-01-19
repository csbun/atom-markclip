fs = require 'fs'
path = require 'path'
mkdirp = require 'mkdirp'
md5 = require 'md5'
PKG = require '../package.json'

TAG_TEXT_EDITOR = 'ATOM-TEXT-EDITOR'
SAVE_TYPE_BASE64 = 'base64'
SAVE_TYPE_FILE = 'file'
SAVE_TYPE_FILE_IN_FOLDER = 'file in folder'
SAVE_TYPE_DEFAULT_FOLDER = 'default folder'
SAVE_TYPE_CUSTOM_FILE = 'custom file'
FILE_EXT = ['.md', '.markdown', '.mdown', '.mkd', '.mkdown']
SPACE_REPLACER = '-';
SPACE_REG = /\s+/g;

module.exports = Markclip =
  config:
    saveType:
      type: 'string'
      description: 'Where to save the clipboard image file'
      default: SAVE_TYPE_BASE64
      enum: [SAVE_TYPE_BASE64, SAVE_TYPE_FILE, SAVE_TYPE_FILE_IN_FOLDER, SAVE_TYPE_DEFAULT_FOLDER, SAVE_TYPE_CUSTOM_FILE]
      order: 10
    folderSpaceReplacer:
      type: 'string'
      description: 'A charset to replace spaces in image floder name'
      default: SPACE_REPLACER
      order: 20
    defaultFolder:
      type: 'string'
      default: 'img'
      order: 30

  handleCtrlVEvent: () ->
    textEditor = atom.workspace.getActiveTextEditor()
    # do nothing if there is no ActiveTextEditor
    return if !textEditor

    # CHECK: do nothing if no image
    clipboard = require('clipboard')
    img = clipboard.readImage()
    return if img.isEmpty()

    # CHECK: do nothing with unsaved file
    filePath = textEditor.getPath()
    if not filePath
      atom.notifications.addWarning(PKG.name + ': Markdown file NOT saved', {
        detail: 'save your file as ' + FILE_EXT.map((n) => '"' + n + '"').join(', ')
      })
      return

    # CHECK: file type should in FILE_EXT
    filePathObj = path.parse(filePath)
    return if FILE_EXT.indexOf(filePathObj.ext) < 0

    saveType = atom.config.get('markclip.saveType')
    # atom 1.12 img.toDataURL / atom 1.11 img.toDataUrl
    imgDataURL = if img.toDataURL then img.toDataURL() else img.toDataUrl()
    # IF:saveType: SAVE AS A FILE
    if (saveType == SAVE_TYPE_FILE_IN_FOLDER || saveType == SAVE_TYPE_FILE)
      imgFileDir = filePathObj.dir
      # IF:saveType: SAVE IN FOLDER or SAVE IN DEFAULT FOLDER, create it
      if saveType == SAVE_TYPE_FILE_IN_FOLDER || saveType == SAVE_TYPE_DEFAULT_FOLDER
        folderSpaceReplacer = atom.config.get('markclip.folderSpaceReplacer').replace(SPACE_REG, '') || SPACE_REPLACER;
        if saveType == SAVE_TYPE_FILE_IN_FOLDER
          imgFileDir = path.join(imgFileDir, filePathObj.name.replace(SPACE_REG, folderSpaceReplacer))
        else
          imgFileDir = path.join(imgFileDir, atom.config.get('markclip.defaultFolder').replace(SPACE_REG, folderSpaceReplacer))
        mkdirp.sync(imgFileDir)
      # create file with md5 name
      imgFilePath = path.join(imgFileDir, @getDefaultImageName(imgDataURL))
      fs.writeFileSync(imgFilePath, img.toPng());
      @insertImgIntoEditor(textEditor, path.relative(filePathObj.dir, imgFilePath))
    # IF:saveType: CUSTOM FILE
    else if saveType == SAVE_TYPE_CUSTOM_FILE
      newItemPath = atom.applicationDelegate.showSaveDialog({
        defaultPath: path.join(filePathObj.dir, @getDefaultImageName(imgDataURL))
      })
      if newItemPath
        fs.writeFileSync(newItemPath, img.toPng());
        @insertImgIntoEditor(textEditor, path.relative(filePathObj.dir, newItemPath))
    # IF:saveType: SAVE AS BASE64
    else
      @insertImgIntoEditor(textEditor, imgDataURL)

  insertImgIntoEditor: (textEditor, src) ->
    textEditor.insertText("![](#{src})\n")
  getDefaultImageName: (imgDataURL) ->
    return md5(imgDataURL).replace('=', '') + '.png'

  activate: (state) ->
    # bind keymaps
    atom.keymaps.onDidMatchBinding((e) =>
      # CHECK: target is TAG_TEXT_EDITOR
      return if ((e.keyboardEventTarget || '').tagName || '') != TAG_TEXT_EDITOR
      # CHECK: cmd-v or ctrl-v
      if e.keystrokes == 'ctrl-v' || e.keystrokes == 'cmd-v'
        @handleCtrlVEvent()
    )

    # atom.contextMenu.add {
    #   'atom-text-editor': [{
    #     label: 'Bookmark-----',
    #     command: 'my-package:toggle'
    #   }]
    # }
    # console.log 'abc'
