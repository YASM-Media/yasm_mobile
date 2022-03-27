import 'package:flutter/material.dart';
import 'package:flutter_offline/flutter_offline.dart';

class LoadingIconButton extends StatelessWidget {
  final bool loading;
  final IconData iconData;
  final VoidCallback onPress;

  final String normalText;
  final String loadingText;

  const LoadingIconButton({
    Key? key,
    required this.loading,
    required this.iconData,
    required this.onPress,
    required this.normalText,
    required this.loadingText,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return OfflineBuilder(
      connectivityBuilder: (
        BuildContext context,
        ConnectivityResult connectivity,
        Widget _,
      ) {
        final bool connected = connectivity != ConnectivityResult.none;
        return ElevatedButton.icon(
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(
              this.loading ? Colors.grey[900]! : Colors.pink,
            ),
          ),
          onPressed: connected
              ? !this.loading
                  ? this.onPress
                  : null
              : null,
          label: Text(
            connected
                ? !this.loading
                    ? this.normalText
                    : this.loadingText
                : 'You are offline',
          ),
          icon: connected
              ? !this.loading
                  ? Icon(
                      this.iconData,
                    )
                  : SizedBox(
                      height: MediaQuery.of(context).size.longestSide * 0.025,
                      width: MediaQuery.of(context).size.longestSide * 0.025,
                      child: CircularProgressIndicator(
                        color: Colors.grey,
                      ),
                    )
              : Icon(
                  Icons.offline_bolt_outlined,
                ),
        );
      },
      child: SizedBox(),
    );
  }
}
