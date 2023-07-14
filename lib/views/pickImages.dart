import 'package:flutter/material.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';

class PickImages extends StatefulWidget {
  const PickImages({Key? key}) : super(key: key);

  @override
  _PickImagesState createState() => _PickImagesState();
}

class _PickImagesState extends State<PickImages> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('图片选项'),
      ),
      body: Column(
        children: [
          TextButton(
            onPressed: () async {
              final List<AssetEntity>? result =
                  await AssetPicker.pickAssets(context, pickerConfig: AssetPickerConfig());
            },
            child: const Text('选择图片'),
          )
        ],
      ),
    );
  }
}
