import 'package:cargo_flutter_app/api/goods_resource_api.dart';
import 'package:cargo_flutter_app/components/modal/common_modal_utils.dart';
import 'package:cargo_flutter_app/components/send/SendGoodItem.dart';
import 'package:cargo_flutter_app/components/united_list/united_list_view.dart';
import 'package:cargo_flutter_app/model/app_response.dart';
import 'package:cargo_flutter_app/model/common_list_params.dart';
import 'package:cargo_flutter_app/model/goods_resource_entity.dart';
import 'package:cargo_flutter_app/theme/colors.dart';
import 'package:cargo_flutter_app/utils/toast_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// 货源请求
typedef Future<AppResponse> GoodsResourceRequest();

/// 发货中，发货历史。常发货源。三合一。

class SendGoodList extends StatefulWidget {
  final int type;

  SendGoodList({this.type});

  @override
  State<StatefulWidget> createState() {
    return _SendGoodListState(type: this.type);
  }
}

class _SendGoodListState extends State<SendGoodList>
    with AutomaticKeepAliveClientMixin {
  int type;

  _SendGoodListState({this.type});

  bool isLoading = true;

  CommonListParams params = CommonListParams<GoodsResourceEntity>(
      isLoading: true, listData: List(), loadingText: '加载中...');

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Container(
      width: double.infinity,
      color: ColorConfig.color_f4f4f4,
      child: Stack(
        children: [
          UnitedListView<GoodsResourceEntity>(
            params: params,
            itemBuilder: (List<GoodsResourceEntity> list, int index) {
              return new SendGoodItem(
                type: type,
                item: list[index],
                action: (actionString) {
                  action(list[index], actionString);
                },
              );
            },
            pageRequest: (int pageNum, int pageSize) {
              return GoodsResourceApi.getMasterPageList(
                  type: type, pageNumber: pageNum, pageSize: pageSize);
            },
            emptyView: Container(
              width: double.infinity,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/no_data.png',
                    width: 325,
                    height: 190,
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 24),
                    child: Text(
                      '您暂时还没有发布的货源哦',
                      style: TextStyle(
                        color: ColorConfig.color33,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            fromJson: (dynamic m) {
              return GoodsResourceEntity().fromJson(m);
            },
          ),
        ],
      ),
    );
  }

  action(GoodsResourceEntity item, String actionStr) {
    switch (actionStr) {
      case DelCollectionAction:
        delCollectAction(item);
        break;
      case CancelCollectionAction:
        cancelCollectionAction(item);
        break;
      case SaveCollectionAction:
        saveCollectionAction(item);
        break;
      case CancelGoodsAction:
        cancelGoodsAction(item);
        break;
      case AgainAction:
        ToastUtils.show(msg: '待跳转发货页面');
        break;
      case ItemAction:
        ToastUtils.show(msg: '待跳转到详情');
        break;
      case DriverAction:
        ToastUtils.show(msg: '待指定司机');
        break;
    }
  }

  /// 收藏
  saveCollectionAction(GoodsResourceEntity item) async {
    setState(() {
      params.loadingText = '正在收藏';
      params.isLoading = true;
    });
    AppResponse response =
        await GoodsResourceApi.goodsResourceOften(id: item.id);
    if (!response.isOk()) {
      ToastUtils.show(msg: response.msg);
      setState(() {
        params.isLoading = false;
      });
      return;
    }
    setState(() {
      item.isOften = 1;
      params.isLoading = false;
    });
    return;
  }

  /// 取消收藏
  cancelCollectionAction(GoodsResourceEntity item) async {
    getCommonModalUtils().showCommonCancelDialog(
      context,
      title: '确定取消收藏么',
      onPressed: () async {
        await removeItemAsync(
          loadingText: '取消中',
          item: item,
          apiReq: () {
            return GoodsResourceApi.goodsResourceOftenCancel(id: item.id);
          },
        );
      },
    );
  }

  // 删除 发货历史 里面的货源
  delCollectAction(GoodsResourceEntity item) async {
    getCommonModalUtils().showCommonCancelDialog(
      context,
      title: '确定取消删除么',
      onPressed: () async {
        await removeItemAsync(
          loadingText: '正在删除',
          item: item,
          apiReq: () {
            return GoodsResourceApi.goodsResourceDel(id: item.id);
          },
        );
      },
    );
  }

  CommonModalUtils commonModalUtils;

  CommonModalUtils getCommonModalUtils() {
    commonModalUtils = commonModalUtils ?? CommonModalUtils();
    return commonModalUtils;
  }

  // 发货中，取消货源
  cancelGoodsAction(GoodsResourceEntity item) async {
    getCommonModalUtils().showCancelReasonModal(context, item, (m) async {
      await removeItemAsync(
          loadingText: '正在取消',
          item: item,
          apiReq: () {
            return GoodsResourceApi.goodsResourceCancel(
                id: item.id, cancelReason: m);
          });
    });
  }

  // 列表有删除操作的地方。 通用的 请求。
  removeItemAsync({
    String loadingText = '删除中',
    GoodsResourceEntity item,
    GoodsResourceRequest apiReq,
  }) async {
    setState(() {
      params.loadingText = loadingText;
      params.isLoading = true;
    });
    AppResponse response = await apiReq();
    if (!response.isOk()) {
      ToastUtils.show(msg: response.msg);
      setState(() {
        params.isLoading = false;
      });
      return;
    }
    for (var bean in params.listData) {
      if (bean.id == item.id) {
        setState(() {
          params.listData.remove(bean);
          params.isLoading = false;
        });
        return;
      }
    }
  }

  @override
  bool get wantKeepAlive => true;
}
