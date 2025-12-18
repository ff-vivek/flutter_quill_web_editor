import 'dart:async';
import 'package:flutter/material.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'package:quill_web_editor/quill_web_editor.dart';

import '../models/document_model.dart';
import '../services/document_db_service.dart';

/// Example page demonstrating the Quill Web Editor package.
class EditorExamplePage extends StatefulWidget {
  final SavedDocument? document;

  const EditorExamplePage({super.key, this.document});

  @override
  State<EditorExamplePage> createState() => _EditorExamplePageState();
}

class _EditorExamplePageState extends State<EditorExamplePage> {
  final GlobalKey<QuillEditorWidgetState> _editorKey = GlobalKey();
  final TextEditingController _titleController = TextEditingController();

  String _currentHtml = '';
  int _wordCount = 0;
  int _charCount = 0;
  double _zoomLevel = 1.0;
  SaveStatus _saveStatus = SaveStatus.saved;
  Timer? _saveTimer;
  SavedDocument? _currentDocument;
  bool _isEditingTitle = false;

  /// Sample content to demonstrate the editor.
  static String _sampleHtml = '''

<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  
  <link href="https://cdn.jsdelivr.net/npm/quill@2/dist/quill.snow.css" rel="stylesheet">
  <link href="https://cdn.jsdelivr.net/npm/quill-table-better@1/dist/quill-table-better.css" rel="stylesheet">
  <link href="https://fonts.googleapis.com/css2?family=Crimson+Pro:wght@400;500;600&family=DM+Sans:wght@400;500;600&family=Roboto:wght@400;500&family=Open+Sans:wght@400;500&family=Lato:wght@400;700&family=Montserrat:wght@400;500;600&family=Source+Code+Pro:wght@400;500&display=swap" rel="stylesheet">
  <style>
* { box-sizing: border-box; margin: 0; padding: 0; }

body { 
  font-family: 'Crimson Pro', Georgia, serif; 
  font-size: 1.125rem;
  line-height: 1.8;
  color: #2c2825;
  background: #ffffff;
  padding: 0;
  margin: 0;
}

.ql-editor { 
  padding: 24px;
  max-width: 100%;
}

/* Typography */
.ql-editor h1 { font-size: 2.25rem; font-weight: 600; margin-bottom: 0.5em; }
.ql-editor h2 { font-size: 1.75rem; font-weight: 600; margin-bottom: 0.5em; }
.ql-editor h3 { font-size: 1.375rem; font-weight: 600; margin-bottom: 0.5em; }
.ql-editor h4 { font-size: 1.125rem; font-weight: 600; margin-bottom: 0.5em; }
.ql-editor h5 { font-size: 0.875rem; font-weight: 600; margin-bottom: 0.5em; }
.ql-editor h6 { font-size: 0.75rem; font-weight: 600; margin-bottom: 0.5em; }
.ql-editor p { margin-bottom: 1em; }
.ql-editor blockquote { border-left: 4px solid #c45d35; padding-left: 16px; margin: 24px 0; color: #6b6560; font-style: italic; }
.ql-editor pre { background: #f8f6f3; border-radius: 8px; padding: 16px; font-family: 'Source Code Pro', monospace; font-size: 0.875rem; overflow-x: auto; }
.ql-editor a { color: #c45d35; text-decoration: underline; }
.ql-editor code { background: #f0f0f0; padding: 2px 4px; border-radius: 3px; font-family: 'Source Code Pro', monospace; }

/* Font family classes */
.ql-font-roboto { font-family: 'Roboto', sans-serif; }
.ql-font-open-sans { font-family: 'Open Sans', sans-serif; }
.ql-font-lato { font-family: 'Lato', sans-serif; }
.ql-font-montserrat { font-family: 'Montserrat', sans-serif; }
.ql-font-source-code { font-family: 'Source Code Pro', sans-serif; }
.ql-font-crimson { font-family: 'Crimson Pro', sans-serif; }
.ql-font-dm-sans { font-family: 'DM Sans', sans-serif; }


/* Font size classes */
.ql-size-small { font-size: 0.75em; }
.ql-size-large { font-size: 1.5em; }
.ql-size-huge { font-size: 2.5em; }

/* Line height classes */
.ql-line-height-1 { line-height: 1; }
.ql-line-height-1-5 { line-height: 1.5; }
.ql-line-height-2 { line-height: 2; }
.ql-line-height-2-5 { line-height: 2.5; }
.ql-line-height-3 { line-height: 3; }

/* Text indent classes */
.ql-indent-1 { padding-left: 3em; }
.ql-indent-2 { padding-left: 6em; }
.ql-indent-3 { padding-left: 9em; }
.ql-indent-4 { padding-left: 12em; }
.ql-indent-5 { padding-left: 15em; }
.ql-indent-6 { padding-left: 18em; }
.ql-indent-7 { padding-left: 21em; }
.ql-indent-8 { padding-left: 24em; }

/* Table styles */
.ql-editor table { border-collapse: collapse; margin: 16px 0; box-sizing: border-box; }
.ql-editor table td, .ql-editor table th { 
  border: 1px solid #e5e0da; 
  min-width: 50px;
  vertical-align: top;
}
.ql-editor table td:not([style*="padding"]), .ql-editor table th:not([style*="padding"]) { 
  padding: 8px 16px; 
}
.ql-editor table.table-with-header tr:first-child td:not([style*="background"]),
.ql-editor table th:not([style*="background"]) { background: #f8f6f3; font-weight: 500; }
.ql-editor table td p { margin: 0; }
.ql-editor table colgroup, .ql-editor table col { display: table-column; }

/* Table alignment */
.ql-editor table.align-left { float: left; margin-right: 16px; margin-bottom: 8px; }
.ql-editor table.align-center { display: table; margin-left: auto; margin-right: auto; }
.ql-editor table.align-right { float: right; margin-left: 16px; margin-bottom: 8px; }

/* List styles */
.ql-editor ul, .ql-editor ol { padding-left: 24px; margin-bottom: 1em; }
.ql-editor li { margin-bottom: 0.5em; }
.ql-editor ul[data-checked="true"] > li::before { content: '☑'; margin-right: 8px; color: #c45d35; }
.ql-editor ul[data-checked="false"] > li::before { content: '☐'; margin-right: 8px; color: #c45d35; }

/* Media styles */
.ql-editor img { max-width: 100%; border-radius: 8px; }
.ql-editor iframe, .ql-editor video, .ql-editor .ql-video { 
  max-width: 100%; 
  display: block; 
  margin: 16px 0;
  border-radius: 8px;
}

/* Media alignment */
.ql-editor img.align-left, .ql-editor iframe.align-left, .ql-editor video.align-left {
  float: left; margin-right: 16px; margin-bottom: 8px;
}
.ql-editor img.align-center, .ql-editor iframe.align-center, .ql-editor video.align-center {
  display: block; margin-left: auto; margin-right: auto; margin-top: 16px; margin-bottom: 16px;
}
.ql-editor img.align-right, .ql-editor iframe.align-right, .ql-editor video.align-right {
  float: right; margin-left: 16px; margin-bottom: 8px;
}

/* Text formatting */
sub { vertical-align: sub; font-size: smaller; }
sup { vertical-align: super; font-size: smaller; }
.ql-direction-rtl { direction: rtl; text-align: inherit; }

/* Text alignment */
.ql-align-center { text-align: center; }
.ql-align-right { text-align: right; }
.ql-align-justify { text-align: justify; }

/* Clear floats */
.ql-editor::after { content: ""; display: table; clear: both; }
.ql-editor p::after { content: ""; display: table; clear: both; }

/* Hide any remaining editor artifacts */
.ql-table-better-selected-td, .ql-table-better-selection-line, .ql-table-better-selection-block,
.ql-table-better-col-tool, .ql-table-better-row-tool, .ql-table-better-corner,
[class*="ql-table-better-select"], [class*="ql-table-better-tool"], temporary {
  display: none !important;
}

  </style>
</head>
<body>
  <div class="ql-editor"><table border="0" cellspacing="0" style="box-sizing: border-box; margin: 16px 0px; padding: 0px; cursor: text; border-collapse: collapse; table-layout: fixed; width: 1333.4px; font-style: normal; font-variant-ligatures: normal; font-variant-caps: normal; font-weight: 400; letter-spacing: normal; orphans: 2; text-transform: none; widows: 2; word-spacing: 0px; -webkit-text-stroke-width: 0px; white-space: normal; text-decoration-thickness: initial; text-decoration-style: initial; text-decoration-color: initial; border: 1px solid black; font-variant-numeric: inherit; font-variant-east-asian: inherit; font-variant-alternates: inherit; font-variant-position: inherit; font-variant-emoji: inherit; font-stretch: inherit; font-size: 15px; line-height: inherit; font-optical-sizing: inherit; font-size-adjust: inherit; font-kerning: inherit; font-feature-settings: inherit; font-variation-settings: inherit; font-language-override: inherit; color: rgb(36, 36, 36); text-align: start; background-color: rgb(160, 48, 37); border-spacing: 0px;" class="ql-table-better x_MsoNormalTable ql-font-roboto ql-font-roboto"><tbody><tr><td style="box-sizing: border-box; margin: 0px; padding: 0cm; border: 1px solid rgb(0, 0, 0); outline: none; min-width: 50px; vertical-align: top; border-collapse: collapse; background: rgb(196, 85, 29); white-space: normal !important;"><p class="ql-table-block"><br></p><p class="ql-table-block"><br></p></td><td style="box-sizing: border-box; margin: 0px; padding: 0cm; border: 1px solid rgb(0, 0, 0); outline: none; min-width: 50px; vertical-align: top; border-collapse: collapse; background: rgb(196, 85, 29); white-space: normal !important;"><p class="ql-table-block ql-align-right"><br></p><p class="ql-table-block ql-align-right"><br></p></td></tr></tbody></table><p><br></p><table border="0" cellspacing="0" style="box-sizing: border-box; margin: 16px 0px; padding: 0px; cursor: text; border-collapse: collapse; table-layout: fixed; width: 1333.4px; font-style: normal; font-variant-ligatures: normal; font-variant-caps: normal; font-weight: 400; letter-spacing: normal; orphans: 2; text-align: left; text-transform: none; widows: 2; word-spacing: 0px; -webkit-text-stroke-width: 0px; white-space: normal; text-decoration-thickness: initial; text-decoration-style: initial; text-decoration-color: initial; font-variant-numeric: inherit; font-variant-east-asian: inherit; font-variant-alternates: inherit; font-variant-position: inherit; font-variant-emoji: inherit; font-stretch: inherit; font-size: 15px; line-height: inherit; font-optical-sizing: inherit; font-size-adjust: inherit; font-kerning: inherit; font-feature-settings: inherit; font-variation-settings: inherit; font-language-override: inherit; color: rgb(36, 36, 36); background-color: rgb(255, 255, 255); border-spacing: 0px;" class="ql-table-better x_x_MsoNormalTable ql-font-roboto ql-font-roboto"><tbody><tr><td width="1295" style="box-sizing: border-box; margin: 0px; padding: 0cm 5.4pt; border: 2.25pt solid windowtext; outline: none; min-width: 50px; vertical-align: top; width: 971.55pt; height: 550.6pt; white-space: normal !important;"><p class="ql-table-block ql-align-justify"><span class="ql-font-roboto" style="color: rgb(36, 36, 36); background-color: rgb(255, 255, 255);">Key Developments:</span></p><ol class="table-list-container" data-width="1295" data-style="white-space: normal !important; width: 971.55pt; border: 2.25pt solid windowtext; padding: 0cm 5.4pt; height: 550.6pt;"><li class="table-list ql-align-justify" data-list="bullet"><span class="ql-ui"></span><span class="ql-font-roboto" style="color: rgb(36, 36, 36); background-color: rgb(255, 255, 255);">Federal Reserve Bank of St. Louis President Alberto Musalem said he expects the US economy to bounce back strongly early next year, underscoring the need for officials to approach additional interest-rate cuts with caution.</span></li><li class="table-list ql-align-justify" data-list="bullet"><span class="ql-ui"></span><span class="ql-font-roboto" style="color: rgb(36, 36, 36); background-color: rgb(255, 255, 255);">A weekend deal to end the longest US government shutdown in history divided Senate Democrats and angered the party's vocal liberal base, who turned their vitriol on Senate Minority Leader Chuck Schumer for the second time this year.</span></li><li class="table-list ql-align-justify" data-list="bullet"><span class="ql-ui"></span><span class="ql-font-roboto" style="color: rgb(36, 36, 36); background-color: rgb(255, 255, 255);">US President Donald Trump said he “at some point” would reduce the tariff rate on Indian goods, saying the US was getting “pretty close” to a trade deal with New Delhi</span></li><li class="table-list ql-align-justify" data-list="bullet"><span class="ql-ui"></span><span class="ql-font-roboto" style="color: rgb(36, 36, 36); background-color: rgb(255, 255, 255);">According to the Periodic labour force survey quarterly bulletin, unemployment rate averaged 5.2% in the September 2025 quarter. This was lower than the 5.4% in the previous quarter. Urban unemployment inched up slightly to 6.9% in the September 2025 quarter from 6.8% in the previous quarter. Rural unemployment eased from 4.8% to 4.4% in the September 2025 quarter.</span></li><li class="table-list ql-align-justify" data-list="bullet"><span class="ql-ui"></span><span class="ql-font-roboto" style="color: rgb(36, 36, 36); background-color: rgb(255, 255, 255);">FDI into India through the government approval route surged more than fivefold to USD 1.4bn during April-June 2025, compared with USD 209mn in the same period last year. FDI inflows through the automatic route also increased, rising to USD 13.5bn from USD 11.8bn a year earlier.</span></li><li class="table-list ql-align-justify" data-list="bullet"><span class="ql-ui"></span><span class="ql-font-roboto" style="color: rgb(36, 36, 36); background-color: rgb(255, 255, 255);">States spent INR 2.5tn, or 26.3% of their INR 9.6tn budgeted capital expenditure during April-September 2025, an analysis of monthly account reports of 20 states released by the Comptroller and Auditor General of India showed.</span></li><li class="table-list ql-align-justify" data-list="bullet"><span class="ql-ui"></span><span class="ql-font-roboto" style="color: rgb(36, 36, 36); background-color: rgb(255, 255, 255);">Leading economists on Monday suggested that a comprehensive manufacturing policy be implemented as the cornerstone for self-reliant growth. In a pre-budget interaction with Finance Minister Nirmala Sitharaman, they also recommended a revamp of the production-linked incentive scheme to include MSMEs and creation of a separate ministry for Artificial Intelligence.</span></li></ol><p class="ql-table-block ql-align-justify"><br></p><p class="ql-table-block ql-align-justify"><span class="ql-font-roboto" style="color: rgb(36, 36, 36); background-color: rgb(255, 255, 255);">Global Market Developments:</span></p><ol class="table-list-container" data-width="1295" data-style="white-space: normal !important; width: 971.55pt; border: 2.25pt solid windowtext; padding: 0cm 5.4pt; height: 550.6pt;"><li class="table-list ql-align-justify" data-list="ordered"><span class="ql-ui"></span><span class="ql-font-roboto" style="color: rgb(36, 36, 36); background-color: rgb(255, 255, 255);">US Stock markets traded largely higher in the previous session: S&amp;P 500 (+1.54%) and Dow Jones (+0.81%).</span></li><li class="table-list ql-align-justify" data-list="ordered"><span class="ql-ui"></span><span class="ql-font-roboto" style="color: rgb(36, 36, 36); background-color: rgb(255, 255, 255);">Asian stock markets traded largely lower this morning: KOSPI (+1.88%), Nikkei (+0.39%) are in green while Hang Seng(-0.11%) Shanghai (-0.26%) and ASX (-0.59%) are in red.</span></li><li class="table-list ql-align-justify" data-list="ordered"><span class="ql-ui"></span><span class="ql-font-roboto" style="color: rgb(36, 36, 36); background-color: rgb(255, 255, 255);">US Treasuries traded lower in the previous session: The 10 Yr US yield is trading at 4.120% vs 4.118% in the previous session</span></li><li class="table-list ql-align-justify" data-list="ordered"><span class="ql-ui"></span><strong class="ql-font-roboto" style="color: rgb(36, 36, 36); background-color: rgb(255, 255, 255);"><u>AU:</u></strong><span class="ql-font-roboto" style="color: rgb(36, 36, 36); background-color: rgb(255, 255, 255);"> Westpac Consumer Conf Index increased from 92.1 to 103.8 in November. NAB Business Confidence fell from 7 to 6 in October.</span></li><li class="table-list ql-indent-1 ql-align-justify" data-list="ordered"><span class="ql-ui"></span><span class="ql-font-roboto" style="color: rgb(36, 36, 36); background-color: rgb(255, 255, 255);">That's great!</span></li></ol><p class="ql-table-block ql-align-justify"><br></p><p class="ql-table-block ql-align-justify"><span class="ql-font-roboto" style="color: rgb(36, 36, 36); background-color: rgb(255, 255, 255);">Domestic market developments:</span></p><p class="ql-table-block ql-align-justify"><span class="ql-font-roboto" style="color: rgb(36, 36, 36); background-color: rgb(255, 255, 255);">The Indian Rupee closed at 88.70 against the USD vs 88.66 in the previous trading session.</span></p><p class="ql-table-block ql-align-justify"><span class="ql-font-roboto" style="color: rgb(36, 36, 36); background-color: rgb(255, 255, 255);">The yield on the 10-year sovereign bond closed at 6.49% vs 6.51% in the previous session.</span></p><p class="ql-table-block ql-align-justify"><span class="ql-font-roboto" style="color: rgb(36, 36, 36); background-color: rgb(255, 255, 255);">Global market roundup</span></p><p class="ql-table-block"><span class="ql-font-roboto" style="color: rgb(36, 36, 36); background-color: rgb(255, 255, 255);"><img src="data:image/gif;base64,R0lGODlhAQABAIAAAAAAAP///yH5BAEAAAEALAAAAAABAAEAAAIBTAA7"></span></p><p class="ql-table-block ql-align-center"><br></p><p class="ql-table-block ql-align-center"><strong class="ql-font-roboto" style="color: rgb(36, 36, 36); background-color: rgb(255, 255, 255);">For more research reports, visit <u><a href="https://www.icicibank.com/corporate/globaltradeservice/research-reports.page?" rel="noopener noreferrer" target="_blank">Economic Research portal </a></u>of ICICI Bank</strong></p><p class="ql-table-block"><br></p><p class="ql-table-block"><br></p><p class="ql-table-block"><br></p><p class="ql-table-block"><br></p><p class="ql-table-block"><br></p></td></tr><tr><td style="box-sizing: border-box; margin: 0px; padding: 0cm 0cm 0cm 6.75pt; border: 1px solid rgb(229, 224, 218); outline: none; min-width: 50px; vertical-align: top; white-space: normal !important;"><p class="ql-table-block ql-align-center"><span class="ql-font-roboto" style="color: rgb(36, 36, 36); background-color: rgb(255, 255, 255);">Regards,</span></p><p class="ql-table-block ql-align-center"><span class="ql-font-roboto" style="color: rgb(36, 36, 36); background-color: rgb(255, 255, 255);">ICICI Bank</span></p><p class="ql-table-block ql-align-center"><br></p><p class="ql-table-block ql-align-center"><strong class="ql-font-roboto" style="color: rgb(36, 36, 36); background-color: rgb(255, 255, 255);">Contact: </strong></p><p class="ql-table-block ql-align-center"><br></p><p class="ql-table-block ql-align-center"><strong class="ql-font-roboto" style="color: rgb(36, 36, 36); background-color: rgb(255, 255, 255);">Economic Research Group</strong></p><p class="ql-table-block ql-align-center"><u class="ql-font-roboto" style="color: rgb(36, 36, 36); background-color: rgb(255, 255, 255);"><a href="mailto:%20erg@icicibank.com" rel="noopener noreferrer" target="_blank">erg@icicibank.com</a></u></p><p class="ql-table-block ql-align-center"><br></p><p class="ql-table-block ql-align-center"><br></p><p class="ql-table-block ql-align-center"><br></p><p class="ql-table-block ql-align-center"><br></p><p class="ql-table-block ql-align-center"><br></p><p class="ql-table-block ql-align-center"><u class="ql-font-roboto" style="color: rgb(36, 36, 36); background-color: rgb(255, 255, 255);"><a href="mailto:unsubscriberesearch@icicibank.com?subject=Unsubscribe%20me&amp;body=Please%20unsubscribe%20me%20from%20Treasury%20Research%20Mailing%20List%20(Kindly%20note:%20To%20unsubscribe%20from%20a%20specific%20report%20type,%20please%20specify%20the%20report%20name%20in%20subject%20line.)&amp;breakTag=%3cbr%3eRegards," rel="noopener noreferrer" target="_blank">Click here to Unsubscribe from Treasury Research mailing list</a></u></p></td></tr></tbody></table><h1><strong class="ql-font-mulish ql-size-huge">Welcome to Quill Editor</strong></h1><p><span class="ql-font-mulish">This is a </span><strong class="ql-font-mulish">rich text editor</strong><span class="ql-font-mulish"> powered by </span><u class="ql-font-mulish" style="color: rgb(196, 93, 53);"><a href="https://quilljs.com" rel="noopener noreferrer" target="_blank">Quill.js</a></u><span class="ql-font-mulish"> and integrated into Flutter.</span></p><h2><strong class="ql-font-mulish ql-size-huge">Features</strong></h2><ol><li data-list="bullet"><span class="ql-ui"></span><span class="ql-font-mulish">Rich text formatting (bold, italic, underline)</span></li><li data-list="bullet"><span class="ql-ui"></span><span class="ql-font-mulish">Headers and paragraphs</span></li><li data-list="bullet"><span class="ql-ui"></span><span class="ql-font-mulish">Lists (ordered and unordered)</span></li><li data-list="bullet"><span class="ql-ui"></span><span class="ql-font-mulish">Links and images</span></li><li data-list="bullet"><span class="ql-ui"></span><span class="ql-font-mulish">Tables with full editing support</span></li><li data-list="bullet"><span class="ql-ui"></span><span class="ql-font-mulish">Undo/Redo support ↩️</span></li><li data-list="bullet"><span class="ql-ui"></span><span class="ql-font-mulish">Emoji picker 😀</span></li><li data-list="bullet"><span class="ql-ui"></span><span class="ql-font-mulish">Markdown shortcuts</span></li></ol><blockquote><em class="ql-font-mulish" style="color: rgb(107, 101, 96);">Try the undo (Ctrl+Z) and redo (Ctrl+Y) buttons above!</em></blockquote><h1><br></h1><p><br></p></div>
</body>
</html>


''';

  @override
  void initState() {
    super.initState();
    _currentDocument = widget.document;
    if (_currentDocument != null) {
      _titleController.text = _currentDocument!.title;
      _wordCount = _currentDocument!.wordCount;
      _charCount = _currentDocument!.charCount;
    }
  }

  String get _initialHtml {
    if (_currentDocument != null && _currentDocument!.html.isNotEmpty) {
      return _currentDocument!.html;
    }
    return '';
  }

  void _onContentChanged(String html, dynamic delta) {
    setState(() {
      _currentHtml = html;
      _saveStatus = SaveStatus.unsaved;
    });

    // Update stats
    final stats = TextStats.fromHtml(html);
    setState(() {
      _wordCount = stats.wordCount;
      _charCount = stats.charCount;
    });

    // Debounced auto-save to database
    _saveTimer?.cancel();
    _saveTimer = Timer(const Duration(milliseconds: 1000), () {
      _autoSaveDocument();
    });
  }

  Future<void> _autoSaveDocument() async {
    if (!mounted) return;

    setState(() => _saveStatus = SaveStatus.saving);

    try {
      if (_currentDocument != null) {
        _currentDocument!.updateContent(
          html: _currentHtml,
          wordCount: _wordCount,
          charCount: _charCount,
        );
        await DocumentDbService.updateDocument(_currentDocument!);
      }

      if (mounted) {
        setState(() => _saveStatus = SaveStatus.saved);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _saveStatus = SaveStatus.unsaved);
      }
    }
  }

  Future<void> _saveDocument() async {
    if (_currentDocument == null) return;

    setState(() => _saveStatus = SaveStatus.saving);

    try {
      _currentDocument!.updateContent(
        title: _titleController.text.isEmpty
            ? 'Untitled Document'
            : _titleController.text,
        html: DocumentService.generateHtmlDocument(_currentHtml),
        wordCount: _wordCount,
        charCount: _charCount,
      );
      await DocumentDbService.updateDocument(_currentDocument!);

      if (mounted) {
        setState(() => _saveStatus = SaveStatus.saved);
        _showSnackBar('Document saved');
      }
    } catch (e) {
      if (mounted) {
        setState(() => _saveStatus = SaveStatus.unsaved);
        _showSnackBar('Failed to save document');
      }
    }
  }

  void _updateTitle(String title) {
    if (_currentDocument != null) {
      _currentDocument!.title = title.isEmpty ? 'Untitled Document' : title;
      _autoSaveDocument();
    }
  }

  @override
  void dispose() {
    print('dispose');
    _saveTimer?.cancel();
    _titleController.dispose();
    super.dispose();
  }

  void _loadSampleContent() {
    _editorKey.currentState?.setHTML(_sampleHtml);
    _showSnackBar('Sample content loaded');
  }

  void _clearEditor() {
    showDialog<void>(
      context: context,
      builder: (context) => PointerInterceptor(
        child: AlertDialog(
          title: const Text('Clear Editor'),
          content: const Text('Are you sure you want to clear all content?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _editorKey.currentState?.clear();
                setState(() {
                  _currentHtml = '';
                  _wordCount = 0;
                  _charCount = 0;
                });
                _showSnackBar('Editor cleared');
              },
              child: const Text('Clear'),
            ),
          ],
        ),
      ),
    );
  }

  void _downloadHtml() {
    if (_currentHtml.isEmpty) {
      _showSnackBar('No content to download');
      return;
    }
    DocumentService.downloadHtml(_currentHtml);
    _showSnackBar('Document downloaded');
  }

  void _generateAndPrintHtml() {
    if (_currentHtml.isEmpty) {
      _showSnackBar('No content to generate');
      return;
    }
    final htmlDocument = DocumentService.generateHtmlDocument(
      _currentHtml,
      cleanHtml: true,
      title: 'Quill Editor Document',
    );
    final separator = '=' * 80;
    print(separator);
    print('Generated HTML Document:');
    print(separator);
    print(htmlDocument);
    print(separator);
    _showSnackBar('HTML document printed to console');
  }

  void _showPreview() {
    if (_currentHtml.isEmpty) {
      _showSnackBar('No content to preview');
      return;
    }
    HtmlPreviewDialog.show(context, _currentHtml);
  }

  void _showInsertHtmlDialog() async {
    final result = await InsertHtmlDialog.show(context);
    if (result != null) {
      _editorKey.currentState?.insertHtml(
        result.html,
        replace: result.replaceContent,
      );
      _showSnackBar('HTML inserted successfully');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Widget _buildTitleField() {
    if (_isEditingTitle) {
      return SizedBox(
        width: 250,
        child: TextField(
          controller: _titleController,
          autofocus: true,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          decoration: InputDecoration(
            isDense: true,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            hintText: 'Document title',
          ),
          onSubmitted: (value) {
            setState(() => _isEditingTitle = false);
            _updateTitle(value);
          },
          onTapOutside: (_) {
            setState(() => _isEditingTitle = false);
            _updateTitle(_titleController.text);
          },
        ),
      );
    }

    return InkWell(
      onTap: () => setState(() => _isEditingTitle = true),
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _currentDocument?.title ?? 'Untitled Document',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(width: 4),
            Icon(Icons.edit, size: 16, color: Colors.grey.shade500),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasDocument = _currentDocument != null;

    return Scaffold(
      appBar: AppBar(
        leading: hasDocument
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context),
                tooltip: 'Back to Dashboard',
              )
            : null,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.accent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.edit_note,
                color: AppColors.accent,
              ),
            ),
            const SizedBox(width: 12),
            if (hasDocument) _buildTitleField() else const Text('Quill Editor'),
          ],
        ),
        actions: [
          // Undo/Redo buttons
          IconButton(
            onPressed: () => _editorKey.currentState?.undo(),
            icon: const Icon(Icons.undo),
            tooltip: 'Undo (Ctrl+Z)',
          ),
          IconButton(
            onPressed: () => _editorKey.currentState?.redo(),
            icon: const Icon(Icons.redo),
            tooltip: 'Redo (Ctrl+Y)',
          ),
          const SizedBox(width: 8),
          // Zoom controls
          ZoomControls(
            zoomLevel: _zoomLevel,
            onZoomIn: () {
              _editorKey.currentState?.zoomIn();
              setState(() {
                _zoomLevel = (_zoomLevel + 0.1).clamp(0.5, 3.0);
              });
            },
            onZoomOut: () {
              _editorKey.currentState?.zoomOut();
              setState(() {
                _zoomLevel = (_zoomLevel - 0.1).clamp(0.5, 3.0);
              });
            },
            onReset: () {
              _editorKey.currentState?.resetZoom();
              setState(() => _zoomLevel = 1.0);
            },
          ),
          const SizedBox(width: 8),
          TextButton.icon(
            onPressed: _showInsertHtmlDialog,
            icon: const Icon(Icons.code),
            label: const Text('Insert HTML'),
          ),
          TextButton.icon(
            onPressed: _loadSampleContent,
            icon: const Icon(Icons.file_download_outlined),
            label: const Text('Sample'),
          ),
          TextButton.icon(
            onPressed: _showPreview,
            icon: const Icon(Icons.preview_outlined),
            label: const Text('Preview'),
          ),
          Tooltip(
            message: 'Generate and print HTML document to console',
            child: TextButton.icon(
              onPressed: _generateAndPrintHtml,
              icon: const Icon(Icons.print_outlined),
              label: const Text('Print HTML'),
            ),
          ),
          TextButton.icon(
            onPressed: _clearEditor,
            icon: const Icon(Icons.delete_outline),
            label: const Text('Clear'),
          ),
          const SizedBox(width: 8),
          SaveStatusIndicator(status: _saveStatus),
          const SizedBox(width: 8),
          if (hasDocument)
            FilledButton.icon(
              onPressed: _saveDocument,
              icon: const Icon(Icons.save),
              label: const Text('Save'),
              
            )
          else
            FilledButton.icon(
              onPressed: _downloadHtml,
              icon: const Icon(Icons.save_alt),
              label: const Text('Export'),
            ),
          const SizedBox(width: 16),
        ],
      ),
      body: Row(
        children: [
          // Editor
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(24),
              decoration: AppTheme.editorContainerDecoration,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: QuillEditorWidget(
                  key: _editorKey,
                  onContentChanged: _onContentChanged,
                  initialHtml: hasDocument ? _initialHtml : _sampleHtml,
                ),
              ),
            ),
          ),
          // Sidebar
          SizedBox(
            width: 320,
            child: Container(
              margin: const EdgeInsets.only(top: 24, right: 24, bottom: 24),
              child: Column(
                children: [
                  // Stats Card
                  AppCard(
                    title: 'Document Info',
                    child: StatCardRow(
                      stats: [
                        (
                          label: 'Words',
                          value: _wordCount.toString(),
                          icon: null
                        ),
                        (
                          label: 'Characters',
                          value: _charCount.toString(),
                          icon: null
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Output Preview Card
                  Expanded(
                    child: Container(
                      decoration: AppTheme.cardDecoration,
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'OUTPUT PREVIEW',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                              color: Colors.grey.shade500,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Expanded(
                            child: OutputPreview(html: _currentHtml),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
