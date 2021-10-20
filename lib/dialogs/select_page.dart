import 'package:flutter/material.dart';
import 'package:statuscenter/clients/pages_client.dart';
import 'package:statuscenter/components/loading.dart';
import 'package:statuscenter/models/page.dart' as PageModel;

class SelectPageDialog extends StatefulWidget {
  final PageModel.Page currentPage;
  final List<PageModel.Page> pages;
  final void Function(PageModel.Page) onChange;

  const SelectPageDialog({Key key, this.currentPage, this.pages, this.onChange})
      : super(key: key);

  @override
  _SelectPageDialogState createState() => _SelectPageDialogState();
}

class _SelectPageDialogState extends State<SelectPageDialog> {
  bool _isLoading = false;
  List<PageModel.Page> _pages;

  @override
  void initState() {
    if (widget.pages == null) {
      _isLoading = true;
      _loadData();
    } else {
      _pages = widget.pages;
    }
    super.initState();
  }

  Future _loadData() async {
    List<PageModel.Page> pages = await new PagesClient().getPages();
    setState(() {
      _pages = pages;
      _isLoading = false;
    });
  }

  void _handleRadioValueChange(PageModel.Page page) {
    Navigator.of(context).pop();
    widget.onChange(page);
  }

  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: _isLoading
              ? [
                  Container(padding: EdgeInsets.all(10), child: Loading()),
                ]
              : [
                  Container(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      'Select your page:',
                      style: Theme.of(context).textTheme.headline6,
                    ),
                  ),
                  ..._pages.map((PageModel.Page page) {
                    return InkWell(
                      onTap: () {
                        _handleRadioValueChange(page);
                      },
                      child: Container(
                        padding: EdgeInsets.only(left: 10, right: 10),
                        child: Row(
                          children: [
                            Radio(
                              onChanged: (dynamic value) {
                                _handleRadioValueChange(value);
                              },
                              groupValue: widget.currentPage != null ??
                                  widget.currentPage.id,
                              value: page.id,
                            ),
                            Text(page.name),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ],
        ),
      ),
    );
  }
}
