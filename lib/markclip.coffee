
fs = require 'fs'
path = require 'path'
mkdirp = require 'mkdirp'
md5 = require 'md5'
PKG = require '../package.json'

SAVE_TYPE_BASE64 = 'base64'
SAVE_TYPE_FILE = 'file'
SAVE_TYPE_FILE_IN_FOLDER = 'file in folder'

FILE_EXT = ['.md', '.markdown', '.mdown', '.mkd', '.mkdown']

module.exports = Markclip =
  config:
    saveType:
      type: 'string'
      description: 'Where to save the clipboard image file'
      default: SAVE_TYPE_BASE64
      enum: [SAVE_TYPE_BASE64, SAVE_TYPE_FILE, SAVE_TYPE_FILE_IN_FOLDER]

  insertImgIntoEditor: (textEditor, src) ->
    textEditor.insertText('![](' + src + ')\n')

  activate: (state) ->
    workspaceElement = atom.views.getView(atom.workspace)
    workspaceElement.addEventListener 'keydown', (e) =>
      textEditor = atom.workspace.getActiveTextEditor()
      # CHECK: cmd + v and there is an ActiveTextEditor
      return if !e.metaKey || e.keyCode != 86 || !textEditor

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
      # IF: save as a file
      if (saveType == SAVE_TYPE_FILE_IN_FOLDER || saveType == SAVE_TYPE_FILE)
        imgFileDir = filePathObj.dir
        # IF: SAVE IN FOLDER, create it
        if saveType == SAVE_TYPE_FILE_IN_FOLDER
          imgFileDir = path.join(imgFileDir, filePathObj.name)
          mkdirp.sync(imgFileDir)
        # create file with md5 name
        imgFilePath = path.join(imgFileDir, md5(img.toDataUrl()).replace('=', '') + '.png')
        fs.writeFileSync(imgFilePath, img.toPng());
        @insertImgIntoEditor(textEditor, path.relative(filePathObj.dir, imgFilePath))
      # IF: save as base64
      else
        @insertImgIntoEditor(textEditor, img.toDataUrl())
