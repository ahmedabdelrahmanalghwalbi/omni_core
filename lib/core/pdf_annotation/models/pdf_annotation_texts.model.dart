part of '../../../omni_core.dart';

/// User-facing texts of the PDF annotation feature.
///
/// The package ships English defaults; a host app passes its own localized
/// instance.
class PdfAnnotationTexts {
  final String annotateAction;
  final String editorTitle;
  final String save;
  final String cancel;
  final String panTool;
  final String penTool;
  final String highlighterTool;
  final String textTool;
  final String eraserTool;
  final String undo;
  final String redo;
  final String strokeSize;
  final String textDialogTitle;
  final String textDialogHint;
  final String textDialogConfirm;
  final String discardChangesTitle;
  final String discardChangesMessage;
  final String discardChangesConfirm;
  final String loadFailedMessage;
  final String saveFailedMessage;

  const PdfAnnotationTexts({
    this.annotateAction = 'Annotate PDF',
    this.editorTitle = 'Annotate PDF',
    this.save = 'Save',
    this.cancel = 'Cancel',
    this.panTool = 'Move',
    this.penTool = 'Pen',
    this.highlighterTool = 'Highlighter',
    this.textTool = 'Text',
    this.eraserTool = 'Eraser',
    this.undo = 'Undo',
    this.redo = 'Redo',
    this.strokeSize = 'Stroke size',
    this.textDialogTitle = 'Add text',
    this.textDialogHint = 'Type your note',
    this.textDialogConfirm = 'Add',
    this.discardChangesTitle = 'Discard changes?',
    this.discardChangesMessage =
        'Your annotations have not been saved and will be lost.',
    this.discardChangesConfirm = 'Discard',
    this.loadFailedMessage =
        'This PDF could not be opened. Please try another file.',
    this.saveFailedMessage =
        'The annotated PDF could not be saved. Please try again.',
  });
}
