import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

class GalleryWidget extends StatefulWidget {

  final String urlImage;
  final  int index;
  final PageController pageController;

  GalleryWidget({
    this.urlImage, 
    this.index = 0, 
  }) : pageController = PageController(initialPage: index);

  @override
  GalleryWidgetState createState() => GalleryWidgetState();
}

class GalleryWidgetState extends State<GalleryWidget> {

  int index;

  @override
  void initState(){

    index = widget.index;

    super.initState();
  }

  @override
    Widget build(BuildContext context) {
      return Scaffold(
        body: Stack(
            children:[
              PhotoViewGallery.builder(
              pageController: widget.pageController,
              itemCount: 1,
              builder: (context, index) {

                final urlImages = widget.urlImage;

                return PhotoViewGalleryPageOptions(
                  imageProvider: NetworkImage(urlImages),
                  minScale: PhotoViewComputedScale.contained,
                  maxScale: PhotoViewComputedScale.contained * 4,
                );
              },
              loadingBuilder: (context, index){
                return Center(child:  SizedBox(
                  child: CircularProgressIndicator(color: Colors.grey, strokeWidth: 2,),
                  height: 35.0,
                  width: 35.0,
                ));
              },
              onPageChanged: (index) => setState(() {
                this.index = index;
              }),
            ),
            if(0 > 1)
            Container(
              alignment: Alignment.bottomRight,
              padding: const EdgeInsets.all(16),
              child: DecoratedBox(
                decoration: BoxDecoration(color: Colors.black.withOpacity(0.8)),
                child: Text(
                'Image ${index + 1}/${widget.urlImage.length}',
                style: TextStyle(color: Colors.white.withOpacity(1), fontSize: 12, fontStyle: FontStyle.italic, background: Paint()
                      ..color = Colors.black.withOpacity(0.8)
                      ..strokeWidth = 20
                      ..strokeJoin = StrokeJoin.round
                      ..strokeCap = StrokeCap.round
                      ..style = PaintingStyle.stroke,
                ),
              )
              ),
            ),
            
            Container(
                margin: const EdgeInsets.fromLTRB(10,30,10,30),
                padding: EdgeInsets.all(0),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(100),
                    color: Colors.black.withOpacity(0.8),
                    //border: Border.all(width: 2, color: Colors.white)),
                ),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_rounded),
                  onPressed: () => Navigator.pop(context),
                  iconSize: 20,
                  color: Colors.white.withOpacity(1),
                )
              ),
            if(!kIsWeb)
            Container(
              margin: const EdgeInsets.fromLTRB(70,30,10,30),
              padding: EdgeInsets.all(0),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(100),
                    color: Colors.black.withOpacity(0.8),
                    //border: Border.all(width: 2, color: Colors.white)),
                ),
              child: IconButton(
                icon: const Icon(Icons.download_outlined),
                onPressed: () async { 
                  //var output = await DialogWidget.dialog(context, true, "Do you want to do this ?", "Description..........................");
                  Fluttertoast.showToast(
                      msg: "Photo enregistrée !",
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.BOTTOM,
                      timeInSecForIosWeb: 1,
                      backgroundColor: Colors.black.withOpacity(0.8),
                  );
                  saveNetworkImage(widget.urlImage);
                },
                iconSize: 24,
                color: Colors.white.withOpacity(0.8),
              )
            ),
          ],
        ),
      );
    }

    void saveNetworkImage(String path) async { // not working on web
      GallerySaver.saveImage(path).then((bool success) {
        setState(() {
          print('Image is saved');
        });
      });
    }

}