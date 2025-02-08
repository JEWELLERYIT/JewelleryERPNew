import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';

// import 'package:pdfx/pdfx.dart';
import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

import '../Constants/StaticConstant.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';

class PdfViewScreen extends StatefulWidget {
  String pathStr = "";

  PdfViewScreen({required this.pathStr});

  @override
  _PdfViewScreenState createState() => _PdfViewScreenState();
}

class _PdfViewScreenState extends State<PdfViewScreen> {
  // PdfController? _pdfController;
  // String? _pdfPath;
  final Completer<PDFViewController> _controller = Completer<PDFViewController>();
  int? pages = 0;
  int? currentPage = 0;
  bool isReady = false;
  String errorMessage = '';


  @override
  void initState() {
    super.initState();

    // print("outputFile.path --1 ${widget.pathStr}");

    // _loadPdf(widget.pathStr);
  }
  Future<void> _loadPdf(String pathStr) async {
    final box = context.findRenderObject() as RenderBox?;

    try {
      // Verify that the file exists and is a valid PDF
      final file = File(pathStr);
      if (await file.exists()) {
        print("Sharing file from path: $pathStr");

        // Share the PDF file
        final shareResult = await Share.shareXFiles(
          [XFile(pathStr)],
          text: 'Check out this PDF file!',
          sharePositionOrigin: box != null
              ? box.localToGlobal(Offset.zero) & box.size
              : Rect.zero, // Use Rect.zero if box is null
        );

        print("Share Result: $shareResult");
      } else {
        print("Error: PDF file not found at path: $pathStr");
      }
    } catch (e) {
      print("Error sharing PDF: $e");
    }
  }


  @override
  void dispose() {
    // _pdfController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            backgroundColor: StaticColor.themeColor,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: const Text(
              'PDF VIEWER',
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.share, color: Colors.white),
                onPressed: () {
                  // Handle share action
                  _loadPdf(widget.pathStr);
                },
              ),
            ]),
        body: PDFView(
          filePath: widget.pathStr,
          enableSwipe: true,
          swipeHorizontal: false,
          autoSpacing: true,
          pageFling: false,
          pageSnap: false,
          fitPolicy: FitPolicy.BOTH,
          backgroundColor: Colors.black,
          onRender: (_pages) {
              setState(() {
                pages = _pages;
                isReady = true;
              });

              // Force re-render to ensure high-quality display
              _controller.future.then((pdfViewController) {
                pdfViewController.setPage(currentPage ?? 0); // Refresh the current page
              });
          },
          onError: (error) {
            setState(() {
              errorMessage = error.toString();
            });
          },
          onPageError: (page, error) {
            setState(() {
              errorMessage = '$page: ${error.toString()}';
            });
          },
          onViewCreated: (PDFViewController pdfViewController) {
            _controller.complete(pdfViewController);
          },
          onPageChanged: (int? page, int? total) {
            setState(() {
              currentPage = page;
            });
          },
        ));
  }
//
// @override
// Widget build(BuildContext context) {
//   return Scaffold(
//     appBar: AppBar(
//       title: Text('PDF Viewer'),
//     ),
//     body: _pdfController != null
//         ? PdfView(
//       controller: _pdfController!,
//     )
//         : Center(child: CircularProgressIndicator()),
//   );
// }
}
