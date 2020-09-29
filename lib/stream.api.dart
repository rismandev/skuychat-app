import 'package:flutter/material.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';

class StreamApi {
  // Function to initial user
  // Client from stream configuration,
  // Id, image, username is user data,
  // token generate by server side.
  static Future initUser(
    Client client, {
    @required String id,
    @required String imageUrl,
    @required String username,
    String token,
  }) async {
    final user = User(
      id: id,
      extraData: {
        'image': imageUrl,
        'name': username,
      },
    );

    // For Development you can use without token
    // you need to disable check authentication on stream dashboard
    await client.setUser(
      user,
      client.devToken(id),
    );
    // Use this for production
    if (token != null) {
      await client.setUser(
        user,
        token,
      );
    }
  }

  // Function to create user channel for chat.
  // Client from stream configuration,
  // channelId, channelName, channelImage, channelMembers is channel data,
  // Return channel data
  static Future<Channel> createChannelOneToOne(
    Client client, {
    @required String channelType,
    @required String channelName,
    @required String channelImage,
    List<String> channelMembers = const [],
  }) async {
    // I dont need channel name & channel image,
    // because I want to create one to one chat
    // If you want to create channel group, you must add channel name & channel image
    final channel = client.channel(
      channelType,
      extraData: {
        'members': channelMembers,
      },
    );
    await channel.create();
    channel.watch();
    return channel;
  }

  // Function to watch channel exist
  // Client from stream configuration,
  // You need to have channelId for watch channel exist
  static Future<Channel> watchChannel(
    Client client, {
    @required String channelType,
    @required String channelId,
  }) async {
    final channel = client.channel(
      channelType,
      id: channelId,
    );
    channel.watch();
    return channel;
  }

  // Function to hide Channel Item
  // Only hide channel, not delete channel,
  // If you like to delete channel,
  // Change channel.hide() to channel.delete()
  static Future<Channel> hideChannel(
    Client client, {
    @required String channelType,
    @required channelId,
  }) async {
    final channel = client.channel(
      channelType,
      id: channelId,
    );
    channel.watch();
    await channel.hide();
    return channel;
  }

  // Function to handle Query User
  // You need to have UserId
  // Return response
  static Future<QueryUsersResponse> queryUser(
    Client client, {
    String id,
  }) async {
    // PASS ID TO FILTER OPTIONS
    final response = await client.queryUsers(
      filter: {
        'id': id,
      },
    );
    return response;
  }
}
