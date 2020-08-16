import 'package:encrypt/bloc/main/main.dart';
import 'package:encrypt/flutter/widget/button.dart';
import 'package:encrypt/flutter/widget/text_input.dart';
import 'package:flutter/material.dart';

class MainPageWidget extends StatelessWidget {
  final MainPageBloc bloc;

  MainPageWidget({Key key, @required this.bloc}) : super(key: key);

  final TextEditingController _textToEncryptController =
      TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
      child: StreamBuilder<MainPageBlocState>(
        stream: bloc.stateStream,
        builder:
            (BuildContext context, AsyncSnapshot<MainPageBlocState> snapshot) {
          if (snapshot.hasData) {
            if (snapshot.hasError) {
              return Text(snapshot.error);
            } else {
              if (snapshot.data.isLoading) {
                return Center(child: CircularProgressIndicator());
              } else {
                if (snapshot.data.hasError) {
                  return Text(snapshot.data.error);
                } else {
                  return _buildActiveState(context, snapshot);
                }
              }
            }
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
    ));
  }

  ListView _buildActiveState(
      BuildContext context, AsyncSnapshot<MainPageBlocState> snapshot) {
    return ListView(
      children: [
        _buildButtonSection(context, snapshot.data),
        _buildSpacer(context),
        TextInputWidget(controller: _textToEncryptController),
        _buildSubmitButton(context),
        _buildTextField(context, snapshot.data),
      ],
    );
  }

  Padding _buildSubmitButton(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: MediaQuery.of(context).size.width / 4),
      child: MainButton(
          backgroundColor: Colors.white,
          textColor: Colors.blue,
          text: "Encrypt Text",
          onTap: () {
            bloc.makeRecord(_textToEncryptController.text);
            _textToEncryptController.value = TextEditingValue.empty;
          }),
    );
  }

  Widget _buildSpacer(BuildContext context) => Container(
        width: MediaQuery.of(context).size.width,
        height: 30,
        child: Icon(Icons.more_horiz),
        decoration: BoxDecoration(
            border: Border.symmetric(
                vertical: BorderSide(color: Colors.black, width: 1))),
      );

  Widget _buildTextField(BuildContext context, MainPageBlocState state) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        height: MediaQuery.of(context).size.height * 2 / 3,
        decoration: BoxDecoration(
            border: Border.all(width: 1, color: Colors.black),
            borderRadius: BorderRadius.all(Radius.circular(8))),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              decoration: BoxDecoration(
                  color: Colors.black12,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(7),
                      topRight: Radius.circular(7))),
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      "Display text in this box",
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (state.records != null)
                      ...state.records
                          ?.map<Widget>((String record) => Text(record))
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildButtonSection(BuildContext context, MainPageBlocState state) {
    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: MediaQuery.of(context).size.width / 4, vertical: 48),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          //TODO(Zaika): implement messages registry
          MainButton(
            text: "Generate Key Pair",
            onTap: () => bloc.generateKeyPair(),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: MainButton(
              isActive: state.hasKeyPair,
              borderColor: state.hasKeyPair ? Colors.blue : Colors.grey,
              backgroundColor: state.hasKeyPair ? Colors.blue : Colors.grey,
              text: "View Private Key",
              onTap: () => bloc.viewPrivateKey(),
            ),
          ),
          MainButton(
            isActive: state.hasKeyPair,
            borderColor: state.hasKeyPair ? Colors.blue : Colors.grey,
            backgroundColor: state.hasKeyPair ? Colors.blue : Colors.grey,
            text: "View Public Key",
            onTap: () => bloc.viewPublicKey(),
          ),
        ],
      ),
    );
  }
}