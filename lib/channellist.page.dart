import 'package:flutter/material.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';
import 'package:test_stream/config.dart';
import 'package:test_stream/stream.api.dart';

class ChannelListPage extends StatefulWidget {
  final Client client;

  ChannelListPage(this.client);

  @override
  _ChannelListPageState createState() => _ChannelListPageState();
}

class _ChannelListPageState extends State<ChannelListPage> {
  // CONTROLLER
  TextEditingController inputNumberController = TextEditingController();
  // STATE
  List<User> dataUser = new List<User>();

  @override
  Widget build(BuildContext context) {
    double topPadding = MediaQuery.of(context).padding.top;
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      builder: (context, child) {
        return StreamChat(
          client: widget.client,
          child: child,
        );
      },
      home: Scaffold(
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            setState(() {
              dataUser = new List<User>();
            });
            displayBottomSheet(context);
          },
          child: Icon(Icons.message),
          backgroundColor: Theme.of(context).primaryColor,
        ),
        body: Column(
          children: [
            Container(
              padding: EdgeInsets.symmetric(vertical: 15),
              margin: EdgeInsets.only(
                top: topPadding,
              ),
              child: Text(
                "SkuyChat.com",
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Expanded(
              child: ChannelsBloc(
                child: ChannelListView(
                  onChannelLongPress: (Channel channel) async {
                    await channel.hide();
                  },
                  filter: {
                    'members': {
                      '\$in': [widget.client.state.user.id],
                    }
                  },
                  sort: [SortOption('last_message_at')],
                  channelWidget: Scaffold(
                    appBar: ChannelHeader(),
                    body: Column(
                      children: <Widget>[
                        Expanded(
                          child: MessageListView(),
                        ),
                        MessageInput(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future handleCreateChannel({
    String memberId,
    String memberName,
    String memberImage,
  }) async {
    final filter = {
      "type": "messaging",
      "members": {
        "\$in": [widget.client.state.user.id, memberId]
      }
    };

    final sort = [
      SortOption("last_message_at", direction: SortOption.DESC),
    ];

    final channels = await widget.client.queryChannels(
      filter: filter,
      sort: sort,
      options: {
        "watch": true,
        "state": true,
      },
    ).last;

    print(channels);

    if (channels.length != 0) {
      Channel channel = channels[0];
      await StreamApi.watchChannel(
        widget.client,
        channelType: "messaging",
        channelId: channel.id,
      );
    } else {
      // CREATE CHANNEL
      final channel = await StreamApi.createChannelOneToOne(
        widget.client,
        channelType: 'messaging',
        channelName: memberName,
        channelImage: memberImage,
        channelMembers: [widget.client.state.user.id, memberId],
      );

      await channel.sendMessage(
        Message(text: 'Halo'),
      );
    }
  }

  void displayBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.orange[200],
                    Colors.orange[600],
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (dataUser.length > 0) ...[
                    Expanded(
                      child: ListView.builder(
                        itemCount: dataUser.length,
                        itemBuilder: (context, index) {
                          User data = dataUser[index];
                          return Container(
                            margin: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: ListTile(
                              onTap: () {
                                if (widget.client.state.user.id != data.id) {
                                  handleCreateChannel(
                                    memberId: data.id,
                                    memberImage: data.extraData['image'],
                                    memberName: data.extraData['image'],
                                  );
                                  Navigator.of(context).pop();
                                  setState(() {
                                    dataUser = new List<User>();
                                  });
                                }
                              },
                              leading: Image.network(
                                data.extraData['image'],
                              ),
                              title: Text(
                                data.extraData['name'],
                              ),
                              subtitle: Text(
                                data.online ? 'Online' : 'Offline',
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ] else ...[
                    Container(
                      padding: EdgeInsets.all(20),
                      margin: EdgeInsets.symmetric(horizontal: 20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        children: [
                          Container(
                            margin: EdgeInsets.only(bottom: 5),
                            child: Text(
                              "Masukan nomor telepon",
                              style: TextStyle(
                                color: Theme.of(context).primaryColor,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.only(bottom: 25),
                            child: Text(
                              "untuk memulai chat",
                              style: TextStyle(
                                color: Theme.of(context).primaryColor,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          inputFieldNumber(),
                          buttonStartChat(
                            context,
                            onPressed: () async {
                              // DATA
                              String phoneNumber = inputNumberController.text;
                              String id = 'skuychat-' + phoneNumber;
                              // QUERY USER DATA
                              final response = await StreamApi.queryUser(
                                widget.client,
                                id: id,
                              );
                              inputNumberController.clear();
                              setState(() {
                                dataUser = response.users;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            );
          },
        );
      },
    );
  }

  Container inputFieldNumber() {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(
        vertical: 15,
      ),
      child: TextFormField(
        controller: this.inputNumberController,
        validator: (String value) {
          if (value.isEmpty) {
            return 'Nomor handphone wajib diisi';
          }
          String validNumber = Config.validationPhoneNumber(value);
          if (validNumber.isNotEmpty) {
            return validNumber;
          }
          return null;
        },
        decoration: InputDecoration(
          hintText: "Nomor handphone",
          contentPadding: EdgeInsets.symmetric(
            vertical: 0,
            horizontal: 15,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(
              color: Colors.grey[400],
              width: 1,
              style: BorderStyle.solid,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(
              color: Colors.grey[400],
              width: 1,
              style: BorderStyle.solid,
            ),
          ),
        ),
      ),
    );
  }

  Container buttonStartChat(
    BuildContext context, {
    Function onPressed,
  }) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            blurRadius: 10,
            color: Colors.grey.withOpacity(0.5),
            offset: Offset.zero,
            spreadRadius: 2,
          ),
        ],
      ),
      child: FlatButton(
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(
            vertical: 10,
          ),
          child: Text(
            "Cari",
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        onPressed: onPressed,
      ),
    );
  }
}
