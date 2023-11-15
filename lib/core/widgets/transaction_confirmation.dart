import 'package:flutter/material.dart';
import 'package:swipeable_button_view/swipeable_button_view.dart';

class TransactionConfirmation extends StatefulWidget {
  final String description;
  final Function callback;
  const TransactionConfirmation({
    super.key,
    required this.description,
    required this.callback,
  });

  @override
  State<TransactionConfirmation> createState() =>
      _TransactionConfirmationState();
}

class _TransactionConfirmationState extends State<TransactionConfirmation> {
  bool finished = false;

  _TransactionConfirmationState();

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      heightFactor: 0.5,
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            children: [
              Text(
                "This action requires your confirmation:",
                textScaleFactor: 1.4,
                style: TextStyle(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const Spacer(),
              Text(widget.description),
              const Spacer(),
              SwipeableButtonView(
                buttonText: 'SLIDE TO CONFIRM',
                buttonWidget: Container(
                  child: Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: Colors.grey,
                  ),
                ),
                activeColor: Color(0xFF009C41),
                isFinished: finished,
                onWaitingProcess: () {
                  Future.delayed(Duration(milliseconds: 400), () {
                    widget.callback();
                    setState(() {
                      finished = true;
                    });
                  });
                },
                onFinish: () async {
                  Navigator.pop(context);
                },
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
