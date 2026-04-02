import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';

import '/flutter_flow/flutter_flow_util.dart';
import 'api_manager.dart';

export 'api_manager.dart' show ApiCallResponse;

const _kPrivateApiFunctionName = 'ffPrivateApiCall';

/// Start Supabase Edge Functions Group Code

class SupabaseEdgeFunctionsGroup {
  static String getBaseUrl() => 'https://punwkcttppysvbmkmohj.supabase.co';
  static Map<String, String> headers = {
    'Authorization':
        'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InB1bndrY3R0cHB5c3ZibWttb2hqIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzUxNTMyNTksImV4cCI6MjA5MDcyOTI1OX0.dwAYotGaxP8NK8rqeEqlbVuDlbITOrUVDNTJC39pX64',
    'apikey':
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InB1bndrY3R0cHB5c3ZibWttb2hqIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzUxNTMyNTksImV4cCI6MjA5MDcyOTI1OX0.dwAYotGaxP8NK8rqeEqlbVuDlbITOrUVDNTJC39pX64',
  };
  static CalculateERCCall calculateERCCall = CalculateERCCall();
  static GetBestDealsCall getBestDealsCall = GetBestDealsCall();
  static WatchlistCall watchlistCall = WatchlistCall();
  static WalletCall walletCall = WalletCall();
}

class CalculateERCCall {
  Future<ApiCallResponse> call({
    String? productId,
    String? storeId,
    double? storePrice,
    String? creditCardId,
    String? loyaltyProgramId,
    String? cashbackProgramId,
    bool? isInternational = false,
  }) async {
    final baseUrl = SupabaseEdgeFunctionsGroup.getBaseUrl();

    final ffApiRequestBody = '''
{
  "product_id": "${escapeStringForJson(productId)}",
  "store_id": "${escapeStringForJson(storeId)}",
  "store_price": ${storePrice},
  "credit_card_id": "${escapeStringForJson(creditCardId)}",
  "loyalty_program_id": "${escapeStringForJson(loyaltyProgramId)}",
  "cashback_program_id": "${escapeStringForJson(cashbackProgramId)}",
  "is_international": ${isInternational}
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'Calculate ERC',
      apiUrl: '${baseUrl}/functions/v1/calculate-erc',
      callType: ApiCallType.POST,
      headers: {
        'Authorization':
            'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InB1bndrY3R0cHB5c3ZibWttb2hqIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzUxNTMyNTksImV4cCI6MjA5MDcyOTI1OX0.dwAYotGaxP8NK8rqeEqlbVuDlbITOrUVDNTJC39pX64',
        'apikey':
            'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InB1bndrY3R0cHB5c3ZibWttb2hqIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzUxNTMyNTksImV4cCI6MjA5MDcyOTI1OX0.dwAYotGaxP8NK8rqeEqlbVuDlbITOrUVDNTJC39pX64',
      },
      params: {},
      body: ffApiRequestBody,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

class GetBestDealsCall {
  Future<ApiCallResponse> call({
    String? productId,
    String? goal = 'CASH',
  }) async {
    final baseUrl = SupabaseEdgeFunctionsGroup.getBaseUrl();

    return ApiManager.instance.makeApiCall(
      callName: 'Get Best Deals',
      apiUrl: '${baseUrl}/functions/v1/get-best-deals',
      callType: ApiCallType.GET,
      headers: {
        'Authorization':
            'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InB1bndrY3R0cHB5c3ZibWttb2hqIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzUxNTMyNTksImV4cCI6MjA5MDcyOTI1OX0.dwAYotGaxP8NK8rqeEqlbVuDlbITOrUVDNTJC39pX64',
        'apikey':
            'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InB1bndrY3R0cHB5c3ZibWttb2hqIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzUxNTMyNTksImV4cCI6MjA5MDcyOTI1OX0.dwAYotGaxP8NK8rqeEqlbVuDlbITOrUVDNTJC39pX64',
      },
      params: {
        'product_id': productId,
        'goal': goal,
      },
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

class WatchlistCall {
  Future<ApiCallResponse> getWatchlist() async {
    final baseUrl = SupabaseEdgeFunctionsGroup.getBaseUrl();

    return ApiManager.instance.makeApiCall(
      callName: 'Get Watchlist',
      apiUrl: '${baseUrl}/functions/v1/watchlist',
      callType: ApiCallType.GET,
      headers: {
        'Authorization':
            'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InB1bndrY3R0cHB5c3ZibWttb2hqIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzUxNTMyNTksImV4cCI6MjA5MDcyOTI1OX0.dwAYotGaxP8NK8rqeEqlbVuDlbITOrUVDNTJC39pX64',
        'apikey':
            'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InB1bndrY3R0cHB5c3ZibWttb2hqIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzUxNTMyNTksImV4cCI6MjA5MDcyOTI1OX0.dwAYotGaxP8NK8rqeEqlbVuDlbITOrUVDNTJC39pX64',
      },
      params: {},
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }

  Future<ApiCallResponse> addToWatchlist({
    String? productId,
    double? targetPrice,
  }) async {
    final baseUrl = SupabaseEdgeFunctionsGroup.getBaseUrl();

    final ffApiRequestBody = '''
{
  "product_id": "${escapeStringForJson(productId)}",
  "target_price": ${targetPrice}
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'Add to Watchlist',
      apiUrl: '${baseUrl}/functions/v1/watchlist',
      callType: ApiCallType.POST,
      headers: {
        'Authorization':
            'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InB1bndrY3R0cHB5c3ZibWttb2hqIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzUxNTMyNTksImV4cCI6MjA5MDcyOTI1OX0.dwAYotGaxP8NK8rqeEqlbVuDlbITOrUVDNTJC39pX64',
        'apikey':
            'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InB1bndrY3R0cHB5c3ZibWttb2hqIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzUxNTMyNTksImV4cCI6MjA5MDcyOTI1OX0.dwAYotGaxP8NK8rqeEqlbVuDlbITOrUVDNTJC39pX64',
      },
      params: {},
      body: ffApiRequestBody,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }

  Future<ApiCallResponse> removeFromWatchlist({
    String? id,
  }) async {
    final baseUrl = SupabaseEdgeFunctionsGroup.getBaseUrl();

    return ApiManager.instance.makeApiCall(
      callName: 'Remove from Watchlist',
      apiUrl: '${baseUrl}/functions/v1/watchlist',
      callType: ApiCallType.DELETE,
      headers: {
        'Authorization':
            'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InB1bndrY3R0cHB5c3ZibWttb2hqIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzUxNTMyNTksImV4cCI6MjA5MDcyOTI1OX0.dwAYotGaxP8NK8rqeEqlbVuDlbITOrUVDNTJC39pX64',
        'apikey':
            'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InB1bndrY3R0cHB5c3ZibWttb2hqIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzUxNTMyNTksImV4cCI6MjA5MDcyOTI1OX0.dwAYotGaxP8NK8rqeEqlbVuDlbITOrUVDNTJC39pX64',
      },
      params: {
        'id': id,
      },
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

class WalletCall {
  Future<ApiCallResponse> getWallet() async {
    final baseUrl = SupabaseEdgeFunctionsGroup.getBaseUrl();

    return ApiManager.instance.makeApiCall(
      callName: 'Get Wallet',
      apiUrl: '${baseUrl}/functions/v1/wallet',
      callType: ApiCallType.GET,
      headers: {
        'Authorization':
            'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InB1bndrY3R0cHB5c3ZibWttb2hqIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzUxNTMyNTksImV4cCI6MjA5MDcyOTI1OX0.dwAYotGaxP8NK8rqeEqlbVuDlbITOrUVDNTJC39pX64',
        'apikey':
            'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InB1bndrY3R0cHB5c3ZibWttb2hqIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzUxNTMyNTksImV4cCI6MjA5MDcyOTI1OX0.dwAYotGaxP8NK8rqeEqlbVuDlbITOrUVDNTJC39pX64',
      },
      params: {},
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }

  Future<ApiCallResponse> addCard({
    String? creditCardId,
    bool? isPrimary = false,
  }) async {
    final baseUrl = SupabaseEdgeFunctionsGroup.getBaseUrl();

    final ffApiRequestBody = '''
{
  "credit_card_id": "${escapeStringForJson(creditCardId)}",
  "is_primary": ${isPrimary}
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'Add Card',
      apiUrl: '${baseUrl}/functions/v1/wallet',
      callType: ApiCallType.POST,
      headers: {
        'Authorization':
            'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InB1bndrY3R0cHB5c3ZibWttb2hqIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzUxNTMyNTksImV4cCI6MjA5MDcyOTI1OX0.dwAYotGaxP8NK8rqeEqlbVuDlbITOrUVDNTJC39pX64',
        'apikey':
            'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InB1bndrY3R0cHB5c3ZibWttb2hqIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzUxNTMyNTksImV4cCI6MjA5MDcyOTI1OX0.dwAYotGaxP8NK8rqeEqlbVuDlbITOrUVDNTJC39pX64',
      },
      params: {},
      body: ffApiRequestBody,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }

  Future<ApiCallResponse> removeCard({
    String? creditCardId,
  }) async {
    final baseUrl = SupabaseEdgeFunctionsGroup.getBaseUrl();

    final ffApiRequestBody = '''
{
  "credit_card_id": "${escapeStringForJson(creditCardId)}"
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'Remove Card',
      apiUrl: '${baseUrl}/functions/v1/wallet',
      callType: ApiCallType.DELETE,
      headers: {
        'Authorization':
            'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InB1bndrY3R0cHB5c3ZibWttb2hqIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzUxNTMyNTksImV4cCI6MjA5MDcyOTI1OX0.dwAYotGaxP8NK8rqeEqlbVuDlbITOrUVDNTJC39pX64',
        'apikey':
            'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InB1bndrY3R0cHB5c3ZibWttb2hqIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzUxNTMyNTksImV4cCI6MjA5MDcyOTI1OX0.dwAYotGaxP8NK8rqeEqlbVuDlbITOrUVDNTJC39pX64',
      },
      params: {},
      body: ffApiRequestBody,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

/// End Supabase Edge Functions Group Code

class ApiPagingParams {
  int nextPageNumber = 0;
  int numItems = 0;
  dynamic lastResponse;

  ApiPagingParams({
    required this.nextPageNumber,
    required this.numItems,
    required this.lastResponse,
  });

  @override
  String toString() =>
      'PagingParams(nextPageNumber: $nextPageNumber, numItems: $numItems, lastResponse: $lastResponse,)';
}

String _toEncodable(dynamic item) {
  return item;
}

String _serializeList(List? list) {
  list ??= <String>[];
  try {
    return json.encode(list, toEncodable: _toEncodable);
  } catch (_) {
    if (kDebugMode) {
      print("List serialization failed. Returning empty list.");
    }
    return '[]';
  }
}

String _serializeJson(dynamic jsonVar, [bool isList = false]) {
  jsonVar ??= (isList ? [] : {});
  try {
    return json.encode(jsonVar, toEncodable: _toEncodable);
  } catch (_) {
    if (kDebugMode) {
      print("Json serialization failed. Returning empty json.");
    }
    return isList ? '[]' : '{}';
  }
}

String? escapeStringForJson(String? input) {
  if (input == null) {
    return null;
  }
  return input
      .replaceAll('\\', '\\\\')
      .replaceAll('"', '\\"')
      .replaceAll('\n', '\\n')
      .replaceAll('\t', '\\t');
}
