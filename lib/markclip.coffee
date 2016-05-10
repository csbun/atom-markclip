
fs = require 'fs'
path = require 'path'
mkdirp = require 'mkdirp'
md5 = require 'md5'
PKG = require '../package.json'

TAG_TEXT_EDITOR = 'ATOM-TEXT-EDITOR'
SAVE_TYPE_BASE64 = 'base64'
SAVE_TYPE_FILE = 'file'
SAVE_TYPE_FILE_IN_FOLDER = 'file in folder'
FILE_EXT = ['.md', '.markdown', '.mdown', '.mkd', '.mkdown']
SPACE_REPLACER = '-';
SPACE_REG = /\s+/g;

module.exports = Markclip =
  config:
    saveType:
      type: 'string'
      description: 'Where to save the clipboard image file'
      default: SAVE_TYPE_BASE64
      enum: [SAVE_TYPE_BASE64, SAVE_TYPE_FILE, SAVE_TYPE_FILE_IN_FOLDER]
    folderSpaceReplacer:
      type: 'string'
      description: 'A charset to replace spaces in image floder name'
      default: SPACE_REPLACER

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
    # IF:saveType: save as a file
    if (saveType == SAVE_TYPE_FILE_IN_FOLDER || saveType == SAVE_TYPE_FILE)
      imgFileDir = filePathObj.dir
      # IF:saveType: SAVE IN FOLDER, create it
      if saveType == SAVE_TYPE_FILE_IN_FOLDER
        folderSpaceReplacer = atom.config.get('markclip.folderSpaceReplacer').replace(SPACE_REG, '') || SPACE_REPLACER;
        imgFileDir = path.join(imgFileDir, filePathObj.name.replace(SPACE_REG, folderSpaceReplacer))
        mkdirp.sync(imgFileDir)
      # create file with md5 name
      imgFilePath = path.join(imgFileDir, md5(img.toDataUrl()).replace('=', '') + '.png')
      fs.writeFileSync(imgFilePath, img.toPng());
      @insertImgIntoEditor(textEditor, path.relative(filePathObj.dir, imgFilePath))
    # IF:saveType: save as base64
    else
      @insertImgIntoEditor(textEditor, img.toDataUrl())

  insertImgIntoEditor: (textEditor, src) ->
    textEditor.insertText('![](' + src + ')\n')

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
