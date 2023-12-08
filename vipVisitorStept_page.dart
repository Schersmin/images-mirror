import 'dart:async';
import 'dart:convert';
import 'dart:ui';

import 'package:date_format/date_format.dart';
import 'package:easy_stepper/easy_stepper.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_swiper_null_safety/flutter_swiper_null_safety.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smartspace_app/compoments/showNaticeBar.dart';
import '../compoments/topTitle.dart';
import '../utils/apiUtils.dart';
import '../compoments/timeSelect.dart';
import '../utils/dateUtils.dart';
import 'package:dio/src/form_data.dart' as dioFormData;

class VipVisitorSteptPage extends StatefulWidget {
  const VipVisitorSteptPage({super.key});

  @override
  _VipVisitorSteptPageState createState() => _VipVisitorSteptPageState();
}

class _VipVisitorSteptPageState extends State<VipVisitorSteptPage>
    with SingleTickerProviderStateMixin {
  final EndTimeChildController endTimeChildController =
      EndTimeChildController(); // 定义一个控制器用于调用子组件(时间)

  late int itemCount; // 声明itemCount变量，值在后期确定

  List<GlobalKey> itemKeys = []; // 空的itemKeys列表

  late int swiperIndexee=0;

  //打印通道对象
  late MethodChannel _methodPrintChannel;

  //打印通道对象
  late EventChannel _eventPrintChannel;

  //输入框对象（步骤一）
  TextEditingController certificateController =
      TextEditingController(text: "");
  TextEditingController fullNameController =
      TextEditingController(text: "");
  TextEditingController certificateNameController =
      TextEditingController(text: "");
  TextEditingController mobileController =
      TextEditingController(text: "");
  TextEditingController companyNameController =
      TextEditingController(text: "");
  TextEditingController emailController =
      TextEditingController(text: "");

  //输入框对象（步骤二）
  TextEditingController certificateEController =
      TextEditingController(text: "");
  TextEditingController fullNameEController =
      TextEditingController(text: "");
  TextEditingController certificateNameEController =
      TextEditingController(text: "");
  TextEditingController mobileEController =
      TextEditingController(text: "");
  TextEditingController companyNameEController =
      TextEditingController(text: "");
  TextEditingController emailEController =
      TextEditingController(text: "");





  // //输入框对象（步骤一）
  // TextEditingController certificateController =
  // new TextEditingController(text: "441424199801244811");
  // TextEditingController fullNameController =
  // new TextEditingController(text: "陈上述");
  // TextEditingController certificateNameController =
  // new TextEditingController(text: "农民证");
  // TextEditingController mobileController =
  // new TextEditingController(text: "15016247751");
  // TextEditingController companyNameController =
  // new TextEditingController(text: "深圳恒迅通科技有限公司");
  //
  // //输入框对象（步骤二）
  // TextEditingController certificateEController =
  // new TextEditingController(text: "441424199801244866");
  // TextEditingController fullNameEController =
  // new TextEditingController(text: "SXXX");
  // TextEditingController certificateNameEController =
  // new TextEditingController(text: "户口本");
  // TextEditingController mobileEController =
  // new TextEditingController(text: "18718942766");
  // TextEditingController companyNameEController =
  // new TextEditingController(text: "深圳恒迅通科技有限公司");
  // TextEditingController emailEController =
  // new TextEditingController(text: "1257209450@qq.com");

  dynamic visitorReasonOption;

  TextEditingController endTimeEController = TextEditingController(
      text: roundToNearestQuarterHour(
          formatterTime(getCurrentTimePlusOneHour())));

  TextEditingController adressEController = TextEditingController(text: "");

  TextEditingController visitToController = TextEditingController(text: "");
  String visitToId = "";
  bool showVisitError = false;
  bool showVisitReasonError = false;
  FocusNode visitReasonFocusNode = FocusNode();

  List<String> adressIds = [];

  //表单对象（步骤2）
  final _formKey1 = GlobalKey<FormState>(); //证件类型表单
  final _formKey2 = GlobalKey<FormState>(); //姓名表单
  final _formKey3 = GlobalKey<FormState>(); //手机号表单
  final _formKey4 = GlobalKey<FormState>(); //公司名称表单
  final _formKey5 = GlobalKey<FormState>(); //电子邮件表单
  final _formKey8 = GlobalKey<FormState>(); //证件名称表单

  //表单对象（步骤3）
  final _formKey6 = GlobalKey<FormState>(); //职位表单
  final _formKey7 = GlobalKey<FormState>(); //访客类型表单

  //表单对象（步骤3）
  final _formKey9 = GlobalKey<FormState>(); //证件类型表单(随行人员)
  final _formKey10 = GlobalKey<FormState>(); //证件名称表单(随行人员)
  final _formKey11 = GlobalKey<FormState>(); //姓名表单(随行人员)
  final _formKey12 = GlobalKey<FormState>(); //手机号表单(随行人员)
  final _formKey13 = GlobalKey<FormState>(); //证件名称表单(随行人员)
  final _formKey14 = GlobalKey<FormState>(); //电子邮件表单(随行人员)

  bool validateEnabled = true; //是否自动校验表单

  bool isEncourageEdict = false; //是否编辑随行访客

  int encourageEdictIndex = 0; //编辑随行访客索引

  //背景图片
  String backgroundImage = '';

  //身份证event对象
  late EventChannel _eventIdCardChannel;

  late StreamSubscription<dynamic> subscription;

  //  证件类型，下拉选项
  List<Map<String, String>> certificateList = [
    {
      "label": "passport".tr,
      "value": 'PASSPORT',
    },
    {
      "label": "id_card".tr,
      "value": 'ID_CARD',
    },
    {
      "label": "other".tr,
      "value": 'OTHER',
    }
  ];


  List<Map<String, String>> certificateListE = [
    {
      "label": "passport".tr,
      "value": 'PASSPORT',
    },
    {
      "label": "id_card".tr,
      "value": 'ID_CARD',
    },
    {
      "label": "other".tr,
      "value": 'OTHER',
    }
  ];

  //待打印数据
  List<dynamic> printData = [];


  //待打印数据
  Map<String,dynamic> printDataOther = {};

  //访问理由下拉菜单
  List<dynamic> visitorReasonOptions = [];

  //随性人员
  List<dynamic> encourageList = [];

  //默认为步骤一
  int activeStep = 0;

  //单选框同意
  late int selectedValue = 0;

  //默认标题
  late String title = "stepts_tv2".tr;

  //是否禁用表单
  bool enableInput = true;

  //默认身份类型
  String? selectedType = "ID_CARD";

  //默认身份类型随行
  String? selectedTypeE = "ID_CARD";






  //默认区号
  String? areaCode = "+86";

  //默认区号随行
  String? areaCode2 = "+86";

  //身份证聚焦对象
  final FocusNode _focusNode = FocusNode();

  //区号聚焦对象
  final FocusNode _focusNode2 = FocusNode();

  // 根据当前语言配置获取对应的翻译信息
  final locale = Get.locale?.toLanguageTag() ?? 'en_US';

  Widget requireIcon = Center(
      child: Text('\ue647',
          style: TextStyle(
              fontFamily: 'Iconfont', color: Colors.red, fontSize: 40.sp)));


  updateIndex(int index){
    setState(() {
      swiperIndexee=index;
    });
  }




  //获得字典选项
  getOption() async {
    dynamic result = await InvitedVisitorAPI.getDictList();
    List<dynamic> visitorTypes = result.data
        .where((element) => element['type'] == 'VISITOR_TYPE')
        .toList();
    List<dynamic> visitorReasons = result.data
        .where((element) => element['type'] == 'VISITOR_REASON')
        .toList();
    visitorReasonOptions = visitorReasons;
  }

  late final _Debounceable<Iterable<dynamic>?, String> _debouncedSearch;

  //搜索被访者
  Future<Iterable<dynamic>?> _search(String query) async {
    dynamic result = await TemporaryVisitorAPI.getVisitTo(query!);
    if (kDebugMode) {
      print(result.data.toString());
    }
    Iterable<dynamic> options;
    if (result.code == '200' && result.data.length > 0) {
      options = result.data;
      return options;
    } else {
      return [];
    }
  }

  getVisiToByReasonOption(String reasonId) async {
    dynamic result = await TemporaryVisitorAPI.getPersonByReasonId(reasonId);
    if (result.code == '200') {
      if (result.data.length > 0) {
        setState(() {
          visitToController.text = result.data[0]['fullName'];
          visitToId = result.data[0]['id'];
          getDefaultAdress(visitToId);
        });
      } else {
        setState(() {
          visitToController.text = "";
          visitToId = "";
        });
      }
    }
  }

  //默认地点
  getDefaultAdress(String id) async {
    dynamic result = await TemporaryVisitorAPI.getPersonDetail(id);
    if (result.code == '200') {
      adressEController.text = result.data['defaultOfficeCountryLabel'] +
          "/" +
          result.data['defaultOfficeCityLabel'] +
          "/" +
          result.data['defaultOfficeBuildingLabel'] +
          "/" +
          result.data['defaultOfficeFloorLabel'];
      setState(() {
        adressIds = [
          result.data['defaultOfficeCountryId'],
          result.data['defaultOfficeCityId'],
          result.data['defaultOfficeBuildingId'],
          result.data['defaultOfficeFloorId']
        ];
      });
    }
  }

  // 更新打印机状态
  void updatePrintState(bool indicate) {
    if (kDebugMode) {
      print("更新打印机状态");
    }
    setState(() {
      // if (indicate) {
      //   printState = "打开";
      // } else {
      //   printState = "关闭";
      // }
    });
  }

  //打开打印端口成功回调
  openPrintScuss() {
    updatePrintState(true);
  }

  //打开打印端口失败回调
  openPrintFail() {
    updatePrintState(false);
  }

  //关闭端口成功回调
  closePrintScuss() {
    updatePrintState(false);
  }

  printCallBack() {
    if (kDebugMode) {
      print("打印回调，打印成功与否都调用");
    }
  }

  @override
  void initState() {
    super.initState();
    getOption();
    _debouncedSearch =
        _debounce<Iterable<dynamic>?, String>((String query) => _search(query));
    visitReasonFocusNode.addListener(() {
      if (visitReasonFocusNode.hasFocus) {
        // 当 visitToFocusNode 获得焦点时触发
        if (kDebugMode) {
          print('visitReasonFocusNode 获得了焦点');
        }
        setState(() {
          showVisitReasonError = true;
        });
      } else {
        // 当 visitToFocusNode 失去焦点时触发
        if (kDebugMode) {
          print('visitReasonFocusNode 失去了焦点');
        }
      }
    });

    _eventIdCardChannel = const EventChannel('IdCardEventChannel');

    //监听_eventPrintChannel消息
    subscription = _eventIdCardChannel.receiveBroadcastStream().listen((event) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (kDebugMode) {
          print('Dart收到消息：$event');
        } // 处理Java发送的消息
        dynamic jsonData = jsonDecode(event);
        if (activeStep == 1 || activeStep == 2) {
          if (jsonData['code'] == 200) {
            String message = jsonData['msg'] as String;
            EasyLoading.showSuccess(message.tr);
          } else {
            EasyLoading.showError(jsonData['msg']);
          }
        }

        if (jsonData['methods'] != null) {
          switch (jsonData['methods']) {
            case 'readIdCardScuss':
              readIdCardScuss(jsonData['data']);
              break;
          }
        }
      });
    });

    _methodPrintChannel = const MethodChannel('PrintChannel');

    _eventPrintChannel = const EventChannel('PrintEventChannel');

    //监听_eventPrintChannel消息
    _eventPrintChannel.receiveBroadcastStream().listen((event) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (kDebugMode) {
          print('Dart收到消息：$event');
        } // 处理Java发送的消息
        dynamic jsonData = jsonDecode(event);
        if (jsonData['code'] == 200) {
          EasyLoading.showSuccess(jsonData['msg']);
        } else {
          EasyLoading.showError(jsonData['msg']);
        }

        if (jsonData['methods'] != null) {
          switch (jsonData['methods']) {
            case 'openPrintScuss':
              openPrintScuss();
              break;
            case 'openPrintFail':
              openPrintFail();
              break;
            case 'closePrintScuss':
              closePrintScuss();
              break;
            case 'printCallBack':
              printCallBack();
              break;
          }
        }
      });
    });
  }

  readIdCardScuss(dynamic data) {
    if (activeStep == 1) {
      if (kDebugMode) {
        print("姓名" + data['fullName']);
      }
      if (kDebugMode) {
        print("身份证" + data['cardNumber']);
      }
      if (kDebugMode) {
        print("证件类型" + data['type']);
      }
      if (data['type'] == '居民身份证') {
        setState(() {
          selectedTypeE = "ID_CARD";
        });
      } else {
        setState(() {
          selectedTypeE = "OTHER";
        });
      }
      certificateEController.text = data['cardNumber'];
      fullNameEController.text = data['fullName'];
    } else if (activeStep == 0) {
      if (kDebugMode) {
        print("姓名" + data['fullName']);
      }
      if (kDebugMode) {
        print("身份证" + data['cardNumber']);
      }
      if (kDebugMode) {
        print("证件类型" + data['type']);
      }
      if (data['type'] == '居民身份证') {
        setState(() {
          selectedType = "ID_CARD";
        });
      } else {
        setState(() {
          selectedType = "OTHER";
        });
      }
      certificateController.text = data['cardNumber'];
      fullNameController.text = data['fullName'];
    }
  }

  @override
  void dispose() {
    super.dispose();
    if (kDebugMode) {
      print("临时访客页面销毁");
    }
    subscription.cancel();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (kDebugMode) {
      print('didChangeDependenciess');
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // 应用从后台回到前台
      if (kDebugMode) {
        print('App resumed');
      }
    } else if (state == AppLifecycleState.paused) {
      // 应用进入后台
      if (kDebugMode) {
        print('App paused');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    /**
     * 前三个步骤表单项
     */
    TextStyle cirTitle = const TextStyle(color: Colors.white);
    TextStyle inputFontStyle =
        TextStyle(fontSize: 32.sp, color: const Color.fromRGBO(121, 121, 121, 1));
    TextStyle inputErrorFontStyle = TextStyle(fontSize: 20.sp, height: 0.9.sp);
    double inputAllHeight = 110.h; //控制包裹表单项整体的大小
    double inputHeight = 70.h; //控制输入框外层大小
    EdgeInsets inputPadding =
        EdgeInsets.symmetric(vertical: 17.h, horizontal: 10.w); //控制真正输入框边框范围内大小
    double boxWidth = 1650.w;
    double itemAllWidth = 1120.w;
    double itemWidth = 1080.w; //单个表单项总宽度
    double itemLeftWidth = 300.w; //标题label总宽度
    double itemRightWidth = 700.w; //输入框总宽度
    double itemLeftTitleWidth = 300.w; //标题label宽度

    /**
     * 第四个步骤特殊的
     */
    double fourItemErrorContainer = 40.h;
    double fouritemLeftWidth = 300.w;
    double fouritemRightWidth = 700.w;

    //下拉菜单右侧图标
    double iconSize = 60.sp;
    Color iconColor = Colors.green.withOpacity(0.7);

    TextStyle custommerErrorFontStyle =
        TextStyle(fontSize: 20.sp, color: Colors.red);

    return Scaffold(
      body: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            FocusScopeNode currentFocus = FocusScope.of(context);
            if (!currentFocus.hasPrimaryFocus) {
              currentFocus.unfocus();
            }
            if (activeStep == 2) {
              if (kDebugMode) {
                print("触发");
              }
              endTimeChildController.closeEndTimeDialog();
            }
          },
          child: SafeArea(
              child: SingleChildScrollView(
                  child: Container(
            width: 1920.w,
            height: 980.h,
            decoration: BoxDecoration(
              color: backgroundImage.isEmpty
                  ? const Color.fromRGBO(248, 248, 248, 1)
                  : null,
              image: backgroundImage.isEmpty
                  ? null
                  : DecorationImage(
                      image: AssetImage(backgroundImage),
                      fit: BoxFit.cover,
                    ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 1720.w,
                  margin: EdgeInsets.fromLTRB(130.0.w, 0, 0, 40.0.h),
                  child: TopTitle(
                      title: title,
                      showDateTime: false,
                      showTime: true,
                      onSelectedValue: () {
                        if (activeStep == 2) {
                          if (kDebugMode) {
                            print("触发");
                          }
                          endTimeChildController.closeEndTimeDialog();
                        }
                      }),
                ),
                Column(
                  children: [
                    Container(
                      margin: EdgeInsets.fromLTRB(135.0.w, 0, 135.w, 0),
                      child: EasyStepper(
                        alignment: Alignment.center,
                        activeStep: activeStep,
                        // padding:EdgeInsetsDirectional.symmetric(horizontal: 0, vertical: 0),
                        lineStyle: LineStyle(
                          lineLength: 350.w,
                          lineThickness: 8.h,
                          lineType: LineType.normal,
                          defaultLineColor: const Color.fromRGBO(51, 51, 51, 1),
                          finishedLineColor: const Color.fromRGBO(2, 198, 21, 1),
                          lineSpace: 20.w,
                        ),
                        activeStepTextColor: const Color.fromRGBO(2, 198, 21, 1),
                        //当前标题的颜色
                        finishedStepTextColor: const Color.fromRGBO(2, 198, 21, 1),
                        internalPadding: 0,
                        showLoadingAnimation: false,
                        stepRadius: 30.w,
                        showStepBorder: false,
                        borderThickness: 0,
                        steps: [
                          EasyStep(
                            customStep: CircleAvatar(
                              radius: 30.w,
                              backgroundColor: activeStep >= 0
                                  ? const Color.fromRGBO(2, 193, 21, 1)
                                  : const Color.fromRGBO(51, 51, 51, 1),
                              child: Center(
                                child: Text(
                                  "1",
                                  style: cirTitle,
                                ),
                              ),
                            ),
                            title: 'stepts_tv2'.tr,
                          ),
                          EasyStep(
                            customStep: CircleAvatar(
                              radius: 30.w,
                              backgroundColor: activeStep >= 1
                                  ? const Color.fromRGBO(2, 193, 21, 1)
                                  : const Color.fromRGBO(51, 51, 51, 1),
                              child: Center(
                                child: Text(
                                  "2",
                                  style: cirTitle,
                                ),
                              ),
                            ),
                            title: 'stepts_tv3'.tr,
                          ),
                          EasyStep(
                            customStep: CircleAvatar(
                              radius: 30.w,
                              backgroundColor: activeStep >= 2
                                  ? const Color.fromRGBO(2, 193, 21, 1)
                                  : const Color.fromRGBO(51, 51, 51, 1),
                              child: Center(
                                child: Text(
                                  "3",
                                  style: cirTitle,
                                ),
                              ),
                            ),
                            title: 'stepts_tv4'.tr,
                          ),
                          EasyStep(
                            customStep: CircleAvatar(
                              radius: 30.w,
                              backgroundColor: activeStep >= 3
                                  ? const Color.fromRGBO(2, 193, 21, 1)
                                  : const Color.fromRGBO(51, 51, 51, 1),
                              child: Center(
                                child: Text(
                                  "4",
                                  style: cirTitle,
                                ),
                              ),
                            ),
                            title: 'stepts_tv5'.tr,
                          ),
                        ],
                        // onStepReached: (index) =>
                        //     setState(() => activeStep = index),
                      ),
                    ),
                    if (activeStep == 0)
                      SizedBox(
                        width: boxWidth,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            //左边表单（访问信息）
                            SizedBox(
                              width: itemAllWidth,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(height: 20.h),
                                  Form(
                                      // 设置自动校验模式
                                      autovalidateMode: validateEnabled
                                          ? AutovalidateMode.onUserInteraction
                                          : AutovalidateMode.disabled,
                                      key: _formKey1,
                                      child: SizedBox(
                                          width: itemWidth,
                                          height: inputAllHeight,
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              Container(
                                                width: itemLeftWidth,
                                                height: inputAllHeight,
                                                padding: EdgeInsets.only(
                                                    bottom: 27.7.h),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.end,
                                                  children: [
                                                    SizedBox(
                                                      width: 30.w,
                                                      child: requireIcon,
                                                    ),
                                                    IntrinsicWidth(
                                                      child: Align(
                                                        alignment: Alignment
                                                            .centerRight,
                                                        child: Text(
                                                          "certificate".tr,
                                                          textAlign:
                                                              TextAlign.right,
                                                          style: TextStyle(
                                                              fontSize: 36.sp,
                                                              color: const Color
                                                                  .fromRGBO(
                                                                      121,
                                                                      121,
                                                                      121,
                                                                      1)),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              SizedBox(
                                                width: itemRightWidth,
                                                height: inputAllHeight,
                                                child: SizedBox(
                                                    width: itemRightWidth,
                                                    height: inputHeight,
                                                    child: TextFormField(
                                                      controller:
                                                          certificateController,
                                                      enabled: enableInput,
                                                      keyboardType: TextInputType.number, // 设置键盘类型为数字键盘
                                                      textAlign:
                                                          TextAlign.start,
                                                      style: inputFontStyle,
                                                      validator: (value) {
                                                        RegExp idCardPattern =
                                                            RegExp(
                                                                r"^\d{17}[\d|x]|\d{15}$");
                                                        if (value!
                                                            .trim()
                                                            .isEmpty) {
                                                          return 'certificateError'
                                                              .tr;
                                                        } else if ( selectedType == 'ID_CARD' && !idCardPattern
                                                            .hasMatch(value!)) {
                                                          return 'certificateRuleError'
                                                              .tr;
                                                        }
                                                        return null;
                                                      },
                                                      decoration:
                                                          InputDecoration(
                                                              contentPadding:
                                                                  inputPadding,
                                                              border: OutlineInputBorder(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(11.0
                                                                              .sp)),
                                                              errorStyle:
                                                                  inputErrorFontStyle,
                                                              prefixIcon:
                                                                  GestureDetector(
                                                                onTap: () {
                                                                  // 点击下拉菜单时取消输入框的聚焦
                                                                  _focusNode
                                                                      .unfocus();
                                                                },
                                                                child:
                                                                    SizedBox(
                                                                  width: 220.w,
                                                                  height:
                                                                      inputHeight,
                                                                  child: Row(
                                                                    children: [
                                                                      Container(
                                                                          width: 200
                                                                              .w,
                                                                          height:
                                                                              inputHeight,
                                                                          decoration:
                                                                              BoxDecoration(
                                                                            border:
                                                                                Border(
                                                                              right: BorderSide(
                                                                                color: Colors.grey,
                                                                                width: 1.0.w,
                                                                              ),
                                                                            ),
                                                                          ),
                                                                          child:
                                                                              DropdownButton(
                                                                            value:
                                                                                selectedType,
                                                                            itemHeight:
                                                                                inputHeight,
                                                                            alignment:
                                                                                Alignment.center,
                                                                            icon:
                                                                                const Icon(Icons.arrow_right),
                                                                            iconSize:
                                                                                iconSize,
                                                                            iconDisabledColor: const Color.fromRGBO(
                                                                                121,
                                                                                121,
                                                                                121,
                                                                                1),
                                                                            iconEnabledColor:
                                                                                iconColor,
                                                                            hint:
                                                                                const Text('证件类型'),
                                                                            isExpanded:
                                                                                true,
                                                                            underline:
                                                                                const SizedBox(),
                                                                            // underline: Container(height: 1, color: Colors.green.withOpacity(0.7)),
                                                                            items:
                                                                                certificateList.map((item) {
                                                                              return DropdownMenuItem(
                                                                                alignment: Alignment.center,
                                                                                value: item['value'],
                                                                                child: Center(
                                                                                  child: Text(item['label']!, style: TextStyle(color: const Color.fromRGBO(121, 121, 121, 1), fontSize: 32.sp)),
                                                                                  // SizedBox(width: 10),
                                                                                  // Icon(Icons.ac_unit),
                                                                                ),
                                                                              );
                                                                            }).toList(),
                                                                            // onChanged: (value) {
                                                                            //   setState(() {
                                                                            //     selectedValue = value as String?;
                                                                            //   });
                                                                            // },
                                                                            onChanged:
                                                                                (String? newValue) {
                                                                              setState(() {
                                                                                selectedType = newValue!;
                                                                                if (kDebugMode) {
                                                                                  print("选择证件类型$newValue");
                                                                                }
                                                                              });
                                                                            },
                                                                          )),
                                                                      Container(
                                                                        width:
                                                                            20.w,
                                                                      )
                                                                    ],
                                                                  ),
                                                                ),
                                                              )),
                                                    )),
                                              ),
                                            ],
                                          ))),
                                  if (selectedType == 'OTHER')
                                    Form(
                                        // 设置自动校验模式
                                        autovalidateMode: validateEnabled
                                            ? AutovalidateMode.onUserInteraction
                                            : AutovalidateMode.disabled,
                                        key: _formKey8,
                                        child: SizedBox(
                                            width: itemWidth,
                                            height: inputAllHeight,
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: [
                                                Container(
                                                  width: itemLeftWidth,
                                                  height: inputAllHeight,
                                                  padding: EdgeInsets.only(
                                                      bottom: 27.7.h),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.end,
                                                    children: [
                                                      SizedBox(
                                                        width: 30.w,
                                                        child: requireIcon,
                                                      ),
                                                      IntrinsicWidth(
                                                        child: Align(
                                                          alignment: Alignment
                                                              .centerRight,
                                                          child: Text(
                                                            "certificateName"
                                                                .tr,
                                                            textAlign:
                                                                TextAlign.right,
                                                            style: TextStyle(
                                                                fontSize: 36.sp,
                                                                color: const Color
                                                                    .fromRGBO(
                                                                        121,
                                                                        121,
                                                                        121,
                                                                        1)),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                SizedBox(
                                                  width: itemRightWidth,
                                                  height: inputAllHeight,
                                                  child: SizedBox(
                                                      width: itemRightWidth,
                                                      height: inputHeight,
                                                      child: TextFormField(
                                                          enabled: enableInput,
                                                          controller:
                                                              certificateNameController,
                                                          textAlign:
                                                              TextAlign.start,
                                                          style: inputFontStyle,
                                                          validator: (value) {
                                                            if (value!
                                                                .trim()
                                                                .isEmpty) {
                                                              return 'certificateNameError'
                                                                  .tr;
                                                            }
                                                            return null;
                                                          },
                                                          decoration:
                                                              InputDecoration(
                                                            contentPadding:
                                                                inputPadding,
                                                            border: OutlineInputBorder(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            11.0.sp)),
                                                            errorStyle:
                                                                inputErrorFontStyle,
                                                          ))),
                                                ),
                                              ],
                                            ))),
                                  Form(
                                      autovalidateMode: validateEnabled
                                          ? AutovalidateMode.onUserInteraction
                                          : AutovalidateMode.disabled,
                                      key: _formKey2,
                                      child: SizedBox(
                                          width: itemWidth,
                                          height: inputAllHeight,
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              Container(
                                                width: itemLeftWidth,
                                                height: inputAllHeight,
                                                padding: EdgeInsets.only(
                                                    bottom: 27.7.h),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.end,
                                                  children: [
                                                    SizedBox(
                                                      width: 30.w,
                                                      child: requireIcon,
                                                    ),
                                                    IntrinsicWidth(
                                                      child: Align(
                                                        alignment: Alignment
                                                            .centerRight,
                                                        child: Text(
                                                          "fullName".tr,
                                                          textAlign:
                                                              TextAlign.right,
                                                          style: TextStyle(
                                                              fontSize: 36.sp,
                                                              color: const Color
                                                                  .fromRGBO(
                                                                      121,
                                                                      121,
                                                                      121,
                                                                      1)),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              SizedBox(
                                                width: itemRightWidth,
                                                height: inputAllHeight,
                                                child: SizedBox(
                                                    width: itemRightWidth,
                                                    height: inputHeight,
                                                    child: TextFormField(
                                                        enabled: enableInput,
                                                        controller:
                                                            fullNameController,
                                                        textAlign:
                                                            TextAlign.start,
                                                        style: inputFontStyle,
                                                        validator: (value) {
                                                          if (value!
                                                              .trim()
                                                              .isEmpty) {
                                                            return 'fullNameError'
                                                                .tr;
                                                          }
                                                          return null;
                                                        },
                                                        decoration:
                                                            InputDecoration(
                                                          contentPadding:
                                                              inputPadding,
                                                          border: OutlineInputBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          11.0.sp)),
                                                          errorStyle:
                                                              inputErrorFontStyle,
                                                        ))),
                                              ),
                                            ],
                                          ))),
                                  Form(
                                      // 设置自动校验模式
                                      autovalidateMode: validateEnabled
                                          ? AutovalidateMode.onUserInteraction
                                          : AutovalidateMode.disabled,
                                      key: _formKey3,
                                      child: SizedBox(
                                          width: itemWidth,
                                          height: inputAllHeight,
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              Container(
                                                width: itemLeftWidth,
                                                height: inputAllHeight,
                                                padding: EdgeInsets.only(
                                                    bottom: 27.7.h),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.end,
                                                  children: [
                                                    SizedBox(
                                                      width: 30.w,
                                                      child: requireIcon,
                                                    ),
                                                    IntrinsicWidth(
                                                      child: Align(
                                                        alignment: Alignment
                                                            .centerRight,
                                                        child: Text(
                                                          "mobile".tr,
                                                          textAlign:
                                                              TextAlign.right,
                                                          style: TextStyle(
                                                              fontSize: 36.sp,
                                                              color: const Color
                                                                  .fromRGBO(
                                                                      121,
                                                                      121,
                                                                      121,
                                                                      1)),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              SizedBox(
                                                width: itemRightWidth,
                                                height: inputAllHeight,
                                                child: SizedBox(
                                                    width: itemRightWidth,
                                                    height: inputHeight,
                                                    child: TextFormField(
                                                      focusNode: _focusNode2,
                                                      controller:
                                                          mobileController,
                                                      keyboardType: TextInputType.number, // 设置键盘类型为数字键盘
                                                      enabled: enableInput,
                                                      textAlign:
                                                          TextAlign.start,
                                                      style: inputFontStyle,
                                                      validator: (value) {
                                                        RegExp mobilePattern =
                                                            RegExp(
                                                                r"^1[3-9]\d{9}$");
                                                        if (value!
                                                            .trim()
                                                            .isEmpty) {
                                                          return 'mobileError'
                                                              .tr;
                                                        } else if (!mobilePattern
                                                            .hasMatch(value!)) {
                                                          return 'mobileRuleError'
                                                              .tr;
                                                        }
                                                        return null;
                                                      },
                                                      decoration:
                                                          InputDecoration(
                                                              contentPadding:
                                                                  inputPadding,
                                                              border: OutlineInputBorder(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(11.0
                                                                              .sp)),
                                                              errorStyle:
                                                                  inputErrorFontStyle,
                                                              prefixIcon:
                                                                  GestureDetector(
                                                                onTap: () {
                                                                  _focusNode2
                                                                      .unfocus();
                                                                  Get.toNamed(
                                                                          "/chooseAreaCode")
                                                                      ?.then(
                                                                          (result) {
                                                                    String
                                                                        receivedData =
                                                                        result
                                                                            as String;
                                                                    // 在这里处理接收到的数据
                                                                    if (kDebugMode) {
                                                                      print(
                                                                        receivedData);
                                                                    }
                                                                    setState(
                                                                        () {
                                                                      areaCode =
                                                                          "+$receivedData";
                                                                    });
                                                                  });
                                                                },
                                                                child:
                                                                    SizedBox(
                                                                  width: 220.w,
                                                                  height:
                                                                      inputHeight,
                                                                  child: Row(
                                                                    children: [
                                                                      Container(
                                                                          width: 200
                                                                              .w,
                                                                          height:
                                                                              inputHeight,
                                                                          // padding: EdgeInsets.all(10),
                                                                          decoration:
                                                                              BoxDecoration(
                                                                            border:
                                                                                Border(
                                                                              right: BorderSide(
                                                                                color: Colors.grey,
                                                                                width: 1.0.w,
                                                                              ),
                                                                            ),
                                                                          ),
                                                                          child:
                                                                              Center(
                                                                            child:
                                                                                Row(
                                                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                              children: [
                                                                                Container(
                                                                                  margin: EdgeInsets.only(left: 20.w),
                                                                                  child: Text(
                                                                                    areaCode!,
                                                                                    style: TextStyle(fontSize: 32.sp, color: const Color.fromRGBO(121, 121, 121, 1)),
                                                                                  ),
                                                                                ),
                                                                                Icon(Icons.arrow_right, size: iconSize, color: iconColor),
                                                                              ],
                                                                            ),
                                                                          )),
                                                                      Container(
                                                                        width:
                                                                            20.w,
                                                                      )
                                                                    ],
                                                                  ),
                                                                ),
                                                              )),
                                                    )),
                                              ),
                                            ],
                                          ))),
                                  // 电子邮件输入框
                                  Form(
                                      // 设置自动校验模式
                                      autovalidateMode: validateEnabled
                                          ? AutovalidateMode.onUserInteraction
                                          : AutovalidateMode.disabled,
                                      key: _formKey5,
                                      child: SizedBox(
                                          width: itemWidth,
                                          height: inputAllHeight,
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              Container(
                                                width: itemLeftWidth,
                                                height: inputAllHeight,
                                                padding: EdgeInsets.only(
                                                    bottom: 27.7.h),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.end,
                                                  children: [
                                                    // Container(
                                                    //   width: 30.w,
                                                    //   child: requireIcon,
                                                    // ),
                                                    IntrinsicWidth(
                                                      child: Align(
                                                        alignment: Alignment
                                                            .centerRight,
                                                        child: Text(
                                                          "email".tr,
                                                          textAlign:
                                                              TextAlign.right,
                                                          style: TextStyle(
                                                              fontSize: 36.sp,
                                                              color: const Color
                                                                  .fromRGBO(
                                                                      121,
                                                                      121,
                                                                      121,
                                                                      1)),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              SizedBox(
                                                width: itemRightWidth,
                                                height: inputAllHeight,
                                                child: SizedBox(
                                                    width: itemRightWidth,
                                                    height: inputHeight,
                                                    child: TextFormField(
                                                        enabled: enableInput,
                                                        controller:
                                                            emailController,
                                                        textAlign:
                                                            TextAlign.start,
                                                        style: inputFontStyle,
                                                        validator: (value) {
                                                          RegExp emailPattern =
                                                              RegExp(
                                                                  r"^[a-zA-Z0-9_-]+@[a-zA-Z0-9_-]+(\.[a-zA-Z0-9_-]+)+$");
                                                          if (value!
                                                              .trim()
                                                              .isEmpty) {
                                                            return 'emailError'
                                                                .tr;
                                                          } else if (!emailPattern
                                                              .hasMatch(
                                                                  value!)) {
                                                            return 'emailRuleError'
                                                                .tr;
                                                          }
                                                          return null;
                                                        },
                                                        decoration:
                                                            InputDecoration(
                                                          contentPadding:
                                                              inputPadding,
                                                          border: OutlineInputBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          11.0.sp)),
                                                          errorStyle:
                                                              inputErrorFontStyle,
                                                        ))),
                                              ),
                                            ],
                                          ))),
                                  Form(
                                      // 设置自动校验模式
                                      autovalidateMode: validateEnabled
                                          ? AutovalidateMode.onUserInteraction
                                          : AutovalidateMode.disabled,
                                      key: _formKey4,
                                      child: SizedBox(
                                          width: itemWidth,
                                          height: inputAllHeight,
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              Container(
                                                width: itemLeftWidth,
                                                height: inputAllHeight,
                                                padding: EdgeInsets.only(
                                                    bottom: 27.7.h),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.end,
                                                  children: [
                                                    // Container(
                                                    //   width: 30.w,
                                                    //   child: requireIcon,
                                                    // ),
                                                    IntrinsicWidth(
                                                      child: Align(
                                                        alignment: Alignment
                                                            .centerRight,
                                                        child: Text(
                                                          "company".tr,
                                                          textAlign:
                                                              TextAlign.right,
                                                          style: TextStyle(
                                                              fontSize: 36.sp,
                                                              color: const Color
                                                                  .fromRGBO(
                                                                      121,
                                                                      121,
                                                                      121,
                                                                      1)),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              SizedBox(
                                                width: itemRightWidth,
                                                height: inputAllHeight,
                                                child: SizedBox(
                                                    width: itemRightWidth,
                                                    height: inputHeight,
                                                    child: TextFormField(
                                                        enabled: enableInput,
                                                        controller:
                                                            companyNameController,
                                                        textAlign:
                                                            TextAlign.start,
                                                        style: inputFontStyle,
                                                        validator: (value) {
                                                          // if (value!
                                                          //     .trim()
                                                          //     .isEmpty) {
                                                          //   return 'companyError'
                                                          //       .tr;
                                                          // }
                                                          return null;
                                                        },
                                                        // controller: textController,
                                                        decoration:
                                                            InputDecoration(
                                                          contentPadding:
                                                              inputPadding,
                                                          border: OutlineInputBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          11.0.sp)),
                                                          errorStyle:
                                                              inputErrorFontStyle,
                                                        ))),
                                              ),
                                            ],
                                          ))),
                                ],
                              ),
                            ),
                            //右边按钮（访问信息）
                            SizedBox(
                              width: 430.w,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 320.w,
                                    height: 75.h,
                                    margin: EdgeInsets.only(right: 20.w),
                                    child: ElevatedButton(
                                      style: ButtonStyle(
                                        backgroundColor:
                                            MaterialStateProperty.all<Color>(
                                                Colors.white),
                                        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                          RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(10.0),
                                            side: const BorderSide(
                                              color: Color.fromRGBO(
                                                  121, 121, 121, 1.0), // 设置边框颜色
                                              width: 1.0, // 设置边框宽度
                                            ),// 调整圆角半径
                                          ),
                                        ),
                                        elevation: MaterialStateProperty.all<double>(1.0),
                                      ),
                                      onPressed: () async {
                                        bool validate1 = (_formKey1.currentState
                                                as FormState)
                                            .validate();
                                        bool validate2 = (_formKey2.currentState
                                                as FormState)
                                            .validate();
                                        bool validate3 = (_formKey3.currentState
                                                as FormState)
                                            .validate();
                                        bool validate4 = (_formKey4.currentState
                                                as FormState)
                                            .validate();

                                        bool validate8 = true;
                                        if (selectedType == 'OTHER') {
                                          validate8 = (_formKey8.currentState
                                                  as FormState)
                                              .validate();
                                        }
                                        if (validate1 &&
                                            validate2 &&
                                            validate3 &&
                                            validate4 &&
                                            (validate8)) {
                                          setState(() {
                                            activeStep = 1;
                                            title = 'stepts_tv3'.tr;
                                          });
                                        }
                                      },
                                      child: Text('addEntourage'.tr,
                                          style: TextStyle(
                                              fontSize: 36.sp,
                                              color: const Color.fromRGBO(
                                                  51, 119, 203, 1))),
                                    ),
                                  ),
                                  SizedBox(height: 50.h),
                                  SizedBox(
                                    width: 320.w,
                                    height: 75.h,
                                    child: ElevatedButton(
                                      style: ButtonStyle(
                                        backgroundColor:
                                            MaterialStateProperty.all<Color>(
                                                const Color.fromRGBO(
                                                    51, 119, 203, 1)),
                                        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                          RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(10.0), // 调整圆角半径
                                          ),
                                        ),
                                      ),
                                      onPressed: () async {
                                        bool validate1 = (_formKey1.currentState
                                                as FormState)
                                            .validate();
                                        bool validate2 = (_formKey2.currentState
                                                as FormState)
                                            .validate();
                                        bool validate3 = (_formKey3.currentState
                                                as FormState)
                                            .validate();
                                        bool validate4 = (_formKey4.currentState
                                                as FormState)
                                            .validate();

                                        bool validate8 = true;
                                        if (selectedType == 'OTHER') {
                                          validate8 = (_formKey8.currentState
                                                  as FormState)
                                              .validate();
                                        }
                                        if (validate1 &&
                                            validate2 &&
                                            validate3 &&
                                            validate4 &&
                                            (validate8)) {
                                          setState(() {
                                            activeStep = 2;
                                            title = 'stepts_tv4'.tr;
                                          });
                                        }
                                      },
                                      child: Text('nextStept'.tr,
                                          style: TextStyle(
                                            fontSize: 36.sp,
                                              color: const Color.fromRGBO(
                                                  255, 255, 255, 1.0)
                                          )),
                                    ),
                                  )
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    if (activeStep == 1)
                      SizedBox(
                          width: boxWidth,
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  //左边表单（访问信息）
                                  SizedBox(
                                    width: itemAllWidth,
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(height: 20.h),
                                        Form(
                                            // 设置自动校验模式
                                            autovalidateMode: validateEnabled
                                                ? AutovalidateMode
                                                    .onUserInteraction
                                                : AutovalidateMode.disabled,
                                            key: _formKey9,
                                            child: SizedBox(
                                                width: itemWidth,
                                                height: inputAllHeight,
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  children: [
                                                    Container(
                                                      width: itemLeftWidth,
                                                      height: inputAllHeight,
                                                      padding: EdgeInsets.only(
                                                          bottom: 27.7.h),
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .end,
                                                        children: [
                                                          // Container(
                                                          //   width: 30.w,
                                                          //   child: requireIcon,
                                                          // ),
                                                          IntrinsicWidth(
                                                            child: Align(
                                                              alignment: Alignment
                                                                  .centerRight,
                                                              child: Text(
                                                                "certificate"
                                                                    .tr,
                                                                textAlign:
                                                                    TextAlign
                                                                        .right,
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        36.sp,
                                                                    color: const Color
                                                                        .fromRGBO(
                                                                            121,
                                                                            121,
                                                                            121,
                                                                            1)),
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      width: itemRightWidth,
                                                      height: inputAllHeight,
                                                      child: SizedBox(
                                                          width: itemRightWidth,
                                                          height: inputHeight,
                                                          child: TextFormField(
                                                            controller:
                                                                certificateEController,
                                                            enabled:
                                                                enableInput,
                                                            keyboardType: TextInputType.number, // 设置键盘类型为数字键盘
                                                            textAlign:
                                                                TextAlign.start,
                                                            style:
                                                                inputFontStyle,
                                                            validator: (value) {
                                                              RegExp
                                                                  idCardPattern =
                                                                  RegExp(
                                                                      r"^\d{17}[\d|x]|\d{15}$");
                                                              if (!idCardPattern
                                                                  .hasMatch(
                                                                      value!) && selectedTypeE == 'ID_CARD' && value.trim().isNotEmpty) {
                                                                return 'certificateRuleError'
                                                                    .tr;
                                                              }
                                                              return null;
                                                            },
                                                            decoration:
                                                                InputDecoration(
                                                                    contentPadding:
                                                                        inputPadding,
                                                                    border: OutlineInputBorder(
                                                                        borderRadius:
                                                                            BorderRadius.circular(11.0
                                                                                .sp)),
                                                                    errorStyle:
                                                                        inputErrorFontStyle,
                                                                    prefixIcon:
                                                                        GestureDetector(
                                                                      onTap:
                                                                          () {
                                                                        // 点击下拉菜单时取消输入框的聚焦
                                                                        _focusNode
                                                                            .unfocus();
                                                                      },
                                                                      child:
                                                                          SizedBox(
                                                                        width:
                                                                            220.w,
                                                                        height:
                                                                            inputHeight,
                                                                        child:
                                                                            Row(
                                                                          children: [
                                                                            Container(
                                                                                width: 200.w,
                                                                                height: inputHeight,
                                                                                decoration: BoxDecoration(
                                                                                  border: Border(
                                                                                    right: BorderSide(
                                                                                      color: Colors.grey,
                                                                                      width: 1.0.w,
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                                child: DropdownButton(
                                                                                  value: selectedTypeE,
                                                                                  itemHeight: inputHeight,
                                                                                  alignment: Alignment.center,
                                                                                  icon: const Icon(Icons.arrow_right),
                                                                                  iconSize: iconSize,
                                                                                  iconDisabledColor: const Color.fromRGBO(121, 121, 121, 1),
                                                                                  iconEnabledColor: iconColor,
                                                                                  hint: const Text('证件类型'),
                                                                                  isExpanded: true,
                                                                                  underline: const SizedBox(),
                                                                                  // underline: Container(height: 1, color: Colors.green.withOpacity(0.7)),
                                                                                  items: certificateListE.map((item) {
                                                                                    return DropdownMenuItem(
                                                                                      alignment: Alignment.center,
                                                                                      value: item['value'],
                                                                                      child: Center(
                                                                                        child: Text(item['label']!, style: TextStyle(color: const Color.fromRGBO(121, 121, 121, 1), fontSize: 32.sp)),
                                                                                        // SizedBox(width: 10),
                                                                                        // Icon(Icons.ac_unit),
                                                                                      ),
                                                                                    );
                                                                                  }).toList(),
                                                                                  onChanged: (String? newValue) {
                                                                                    setState(() {
                                                                                      selectedTypeE = newValue!;
                                                                                    });
                                                                                  },
                                                                                )),
                                                                            Container(
                                                                              width: 20.w,
                                                                            )
                                                                          ],
                                                                        ),
                                                                      ),
                                                                    )),
                                                          )),
                                                    ),
                                                  ],
                                                ))),
                                        if (selectedTypeE == 'OTHER')
                                          Form(
                                              // 设置自动校验模式
                                              autovalidateMode: validateEnabled
                                                  ? AutovalidateMode
                                                      .onUserInteraction
                                                  : AutovalidateMode.disabled,
                                              key: _formKey10,
                                              child: SizedBox(
                                                  width: itemWidth,
                                                  height: inputAllHeight,
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    children: [
                                                      Container(
                                                        width: itemLeftWidth,
                                                        height: inputAllHeight,
                                                        padding:
                                                            EdgeInsets.only(
                                                                bottom: 27.7.h),
                                                        child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .end,
                                                          children: [
                                                            SizedBox(
                                                              width: 30.w,
                                                              child:
                                                                  requireIcon,
                                                            ),
                                                            IntrinsicWidth(
                                                              child: Align(
                                                                alignment: Alignment
                                                                    .centerRight,
                                                                child: Text(
                                                                  "certificateName"
                                                                      .tr,
                                                                  textAlign:
                                                                      TextAlign
                                                                          .right,
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          36.sp,
                                                                      color: const Color.fromRGBO(
                                                                          121,
                                                                          121,
                                                                          121,
                                                                          1)),
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        width: itemRightWidth,
                                                        height: inputAllHeight,
                                                        child: SizedBox(
                                                            width:
                                                                itemRightWidth,
                                                            height: inputHeight,
                                                            child:
                                                                TextFormField(
                                                                    enabled:
                                                                        enableInput,
                                                                    controller:
                                                                        certificateNameEController,
                                                                    textAlign:
                                                                        TextAlign
                                                                            .start,
                                                                    style:
                                                                        inputFontStyle,
                                                                    validator:
                                                                        (value) {
                                                                      if (value!
                                                                          .trim()
                                                                          .isEmpty) {
                                                                        return 'certificateNameError'
                                                                            .tr;
                                                                      }
                                                                      return null;
                                                                    },
                                                                    decoration:
                                                                        InputDecoration(
                                                                      contentPadding:
                                                                          inputPadding,
                                                                      border: OutlineInputBorder(
                                                                          borderRadius:
                                                                              BorderRadius.circular(11.0.sp)),
                                                                      errorStyle:
                                                                          inputErrorFontStyle,
                                                                    ))),
                                                      ),
                                                    ],
                                                  ))),
                                        Form(
                                            autovalidateMode: validateEnabled
                                                ? AutovalidateMode
                                                    .onUserInteraction
                                                : AutovalidateMode.disabled,
                                            key: _formKey11,
                                            child: SizedBox(
                                                width: itemWidth,
                                                height: inputAllHeight,
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  children: [
                                                    Container(
                                                      width: itemLeftWidth,
                                                      height: inputAllHeight,
                                                      padding: EdgeInsets.only(
                                                          bottom: 27.7.h),
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .end,
                                                        children: [
                                                          SizedBox(
                                                            width: 30.w,
                                                            child: requireIcon,
                                                          ),
                                                          IntrinsicWidth(
                                                            child: Align(
                                                              alignment: Alignment
                                                                  .centerRight,
                                                              child: Text(
                                                                "fullName".tr,
                                                                textAlign:
                                                                    TextAlign
                                                                        .right,
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        36.sp,
                                                                    color: const Color
                                                                        .fromRGBO(
                                                                            121,
                                                                            121,
                                                                            121,
                                                                            1)),
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      width: itemRightWidth,
                                                      height: inputAllHeight,
                                                      child: SizedBox(
                                                          width: itemRightWidth,
                                                          height: inputHeight,
                                                          child: TextFormField(
                                                              enabled:
                                                                  enableInput,
                                                              controller:
                                                                  fullNameEController,
                                                              textAlign:
                                                                  TextAlign
                                                                      .start,
                                                              style:
                                                                  inputFontStyle,
                                                              validator:
                                                                  (value) {
                                                                if (value!
                                                                    .trim()
                                                                    .isEmpty) {
                                                                  return 'fullNameError'
                                                                      .tr;
                                                                }
                                                                return null;
                                                              },
                                                              decoration:
                                                                  InputDecoration(
                                                                contentPadding:
                                                                    inputPadding,
                                                                border: OutlineInputBorder(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            11.0.sp)),
                                                                errorStyle:
                                                                    inputErrorFontStyle,
                                                              ))),
                                                    ),
                                                  ],
                                                ))),
                                        Form(
                                            // 设置自动校验模式
                                            autovalidateMode: validateEnabled
                                                ? AutovalidateMode
                                                    .onUserInteraction
                                                : AutovalidateMode.disabled,
                                            key: _formKey12,
                                            child: SizedBox(
                                                width: itemWidth,
                                                height: inputAllHeight,
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  children: [
                                                    Container(
                                                      width: itemLeftWidth,
                                                      height: inputAllHeight,
                                                      padding: EdgeInsets.only(
                                                          bottom: 27.7.h),
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .end,
                                                        children: [
                                                          SizedBox(
                                                            width: 30.w,
                                                            child: requireIcon,
                                                          ),
                                                          IntrinsicWidth(
                                                            child: Align(
                                                              alignment: Alignment
                                                                  .centerRight,
                                                              child: Text(
                                                                "mobile".tr,
                                                                textAlign:
                                                                    TextAlign
                                                                        .right,
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        36.sp,
                                                                    color: const Color
                                                                        .fromRGBO(
                                                                            121,
                                                                            121,
                                                                            121,
                                                                            1)),
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      width: itemRightWidth,
                                                      height: inputAllHeight,
                                                      child: SizedBox(
                                                          width: itemRightWidth,
                                                          height: inputHeight,
                                                          child: TextFormField(
                                                            focusNode:
                                                                _focusNode2,
                                                            controller:
                                                                mobileEController,
                                                            keyboardType: TextInputType.number, // 设置键盘类型为数字键盘
                                                            enabled:
                                                                enableInput,
                                                            textAlign:
                                                                TextAlign.start,
                                                            style:
                                                                inputFontStyle,
                                                            validator: (value) {
                                                              RegExp
                                                                  mobilePattern =
                                                                  RegExp(
                                                                      r"^1[3-9]\d{9}$");
                                                              if (value!
                                                                  .trim()
                                                                  .isEmpty) {
                                                                return 'mobileError'
                                                                    .tr;
                                                              } else if (!mobilePattern
                                                                  .hasMatch(
                                                                      value!)) {
                                                                return 'mobileRuleError'
                                                                    .tr;
                                                              }
                                                              return null;
                                                            },
                                                            decoration:
                                                                InputDecoration(
                                                                    contentPadding:
                                                                        inputPadding,
                                                                    border: OutlineInputBorder(
                                                                        borderRadius:
                                                                            BorderRadius.circular(11.0
                                                                                .sp)),
                                                                    errorStyle:
                                                                        inputErrorFontStyle,
                                                                    prefixIcon:
                                                                        GestureDetector(
                                                                      onTap:
                                                                          () {
                                                                        _focusNode2
                                                                            .unfocus();
                                                                        Get.toNamed("/chooseAreaCode")
                                                                            ?.then((result) {
                                                                          String
                                                                              receivedData =
                                                                              result as String;
                                                                          // 在这里处理接收到的数据
                                                                          if (kDebugMode) {
                                                                            print(
                                                                              receivedData);
                                                                          }
                                                                          setState(
                                                                              () {
                                                                            areaCode =
                                                                                "+$receivedData";
                                                                          });
                                                                        });
                                                                      },
                                                                      child:
                                                                          SizedBox(
                                                                        width:
                                                                            220.w,
                                                                        height:
                                                                            inputHeight,
                                                                        child:
                                                                            Row(
                                                                          children: [
                                                                            Container(
                                                                                width: 200.w,
                                                                                height: inputHeight,
                                                                                // padding: EdgeInsets.all(10),
                                                                                decoration: BoxDecoration(
                                                                                  border: Border(
                                                                                    right: BorderSide(
                                                                                      color: Colors.grey,
                                                                                      width: 1.0.w,
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                                child: Center(
                                                                                  child: Row(
                                                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                    children: [
                                                                                      Container(
                                                                                        margin: EdgeInsets.only(left: 20.w),
                                                                                        child: Text(
                                                                                          areaCode!,
                                                                                          style: TextStyle(fontSize: 32.sp, color: const Color.fromRGBO(121, 121, 121, 1)),
                                                                                        ),
                                                                                      ),
                                                                                      Icon(Icons.arrow_right, size: iconSize, color: iconColor),
                                                                                    ],
                                                                                  ),
                                                                                )),
                                                                            Container(
                                                                              width: 20.w,
                                                                            )
                                                                          ],
                                                                        ),
                                                                      ),
                                                                    )),
                                                          )),
                                                    ),
                                                  ],
                                                ))),
                                        Form(
                                            // 设置自动校验模式
                                            autovalidateMode: validateEnabled
                                                ? AutovalidateMode
                                                    .onUserInteraction
                                                : AutovalidateMode.disabled,
                                            key: _formKey13,
                                            child: SizedBox(
                                                width: itemWidth,
                                                height: inputAllHeight,
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  children: [
                                                    Container(
                                                      width: itemLeftWidth,
                                                      height: inputAllHeight,
                                                      padding: EdgeInsets.only(
                                                          bottom: 27.7.h),
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .end,
                                                        children: [
                                                          SizedBox(
                                                            width: 30.w,
                                                            child: requireIcon,
                                                          ),
                                                          IntrinsicWidth(
                                                            child: Align(
                                                              alignment: Alignment
                                                                  .centerRight,
                                                              child: Text(
                                                                "company".tr,
                                                                textAlign:
                                                                    TextAlign
                                                                        .right,
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        36.sp,
                                                                    color: const Color
                                                                        .fromRGBO(
                                                                            121,
                                                                            121,
                                                                            121,
                                                                            1)),
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      width: itemRightWidth,
                                                      height: inputAllHeight,
                                                      child: SizedBox(
                                                          width: itemRightWidth,
                                                          height: inputHeight,
                                                          child: TextFormField(
                                                              enabled:
                                                                  enableInput,
                                                              controller:
                                                                  companyNameEController,
                                                              textAlign:
                                                                  TextAlign
                                                                      .start,
                                                              style:
                                                                  inputFontStyle,
                                                              validator:
                                                                  (value) {
                                                                if (value!
                                                                    .trim()
                                                                    .isEmpty) {
                                                                  return 'companyError'
                                                                      .tr;
                                                                }
                                                                return null;
                                                              },
                                                              // controller: textController,
                                                              decoration:
                                                                  InputDecoration(
                                                                contentPadding:
                                                                    inputPadding,
                                                                border: OutlineInputBorder(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            11.0.sp)),
                                                                errorStyle:
                                                                    inputErrorFontStyle,
                                                              ))),
                                                    ),
                                                  ],
                                                ))),
                                      ],
                                    ),
                                  ),
                                  //右边按钮（访问信息）
                                  SizedBox(
                                    width: 430.w,
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          width: 320.w,
                                          height: 75.h,
                                          margin: EdgeInsets.only(right: 20.w),
                                          child: ElevatedButton(
                                            style: ButtonStyle(
                                              backgroundColor:
                                                  MaterialStateProperty.all<
                                                      Color>(Colors.white),
                                              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                                RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(10.0),
                                                  side: const BorderSide(
                                                    color: Color.fromRGBO(
                                                        121, 121, 121, 1.0), // 设置边框颜色
                                                    width: 1.0, // 设置边框宽度
                                                  ),// 调整圆角半径
                                                ),
                                              ),
                                              elevation: MaterialStateProperty.all<double>(1.0),
                                            ),
                                            onPressed: () async {
                                              setState(() {
                                                activeStep = 0;
                                                title = "stepts_tv2".tr;
                                              });
                                            },
                                            child: Text('lastStept'.tr,
                                                style: TextStyle(
                                                    fontSize: 36.sp,
                                                    color: const Color.fromRGBO(
                                                        51, 119, 203, 1))),
                                          ),
                                        ),
                                        SizedBox(height: 50.h),
                                        Container(
                                          width: 320.w,
                                          height: 75.h,
                                          margin: EdgeInsets.only(right: 20.w),
                                          child: ElevatedButton(
                                            style: ButtonStyle(
                                              backgroundColor:
                                                  MaterialStateProperty.all<
                                                      Color>(Colors.white),
                                              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                                RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(10.0),
                                                  side: const BorderSide(
                                                    color: Color.fromRGBO(
                                                        121, 121, 121, 1.0), // 设置边框颜色
                                                    width: 1.0, // 设置边框宽度
                                                  ),// 调整圆角半径
                                                ),
                                              ),
                                              elevation: MaterialStateProperty.all<double>(1.0),
                                            ),
                                            onPressed: () async {
                                              bool validate9 =
                                                  (_formKey9.currentState
                                                          as FormState)
                                                      .validate();
                                              bool validate11 =
                                                  (_formKey11.currentState
                                                          as FormState)
                                                      .validate();
                                              bool validate12 =
                                                  (_formKey12.currentState
                                                          as FormState)
                                                      .validate();
                                              bool validate13 =
                                                  (_formKey13.currentState
                                                          as FormState)
                                                      .validate();

                                              bool validate10 = true;
                                              if (selectedTypeE == 'OTHER') {
                                                validate10 =
                                                    (_formKey10.currentState
                                                            as FormState)
                                                        .validate();
                                              }
                                              if (validate9 &&
                                                  validate11 &&
                                                  validate12 &&
                                                  validate13 &&
                                                  (validate10)) {
                                                dynamic encourage = {
                                                  "certificateNo":
                                                      certificateEController
                                                          .text,
                                                  "certificateType":
                                                      selectedTypeE,
                                                  "fullName":
                                                      fullNameEController.text,
                                                  "mobile":
                                                      mobileEController.text,
                                                  "companyName":
                                                      companyNameEController
                                                          .text,
                                                };
                                                if (selectedTypeE == 'OTHER') {
                                                  encourage['certificateName'] =
                                                      certificateNameEController
                                                          .text;
                                                }

                                                if (isEncourageEdict) {
                                                  setState(() {
                                                    bool isDuplicate = false;
                                                    for (var i = 0;
                                                        i <
                                                            encourageList
                                                                .length;
                                                        i++) {
                                                      if (encourageList[i][
                                                                  'fullName'] ==
                                                              encourage[
                                                                  'fullName'] &&
                                                          i !=
                                                              encourageEdictIndex) {
                                                        isDuplicate = true;
                                                        break;
                                                      }
                                                    }

                                                    if (isDuplicate) {
                                                      showNoticeBarRed(
                                                          "accompany".tr +
                                                              "：" +
                                                              encourage[
                                                                  'fullName'] +
                                                              "alreadyExit".tr);
                                                    } else {
                                                      showNoticeBarGreen(
                                                          "accompany".tr +
                                                              "：" +
                                                              encourage[
                                                                  'fullName'] +
                                                              "edictScuss".tr);
                                                      encourageList.removeAt(
                                                          encourageEdictIndex);
                                                      encourageList
                                                          .add(encourage);

                                                      certificateEController
                                                          .clear();
                                                      fullNameEController
                                                          .clear();
                                                      mobileEController.clear();
                                                      companyNameEController
                                                          .clear();
                                                      if (selectedTypeE ==
                                                          'OTHER') {
                                                        certificateNameEController
                                                            .clear();
                                                      }
                                                      WidgetsBinding.instance
                                                          .addPostFrameCallback(
                                                              (_) {
                                                        _formKey9.currentState
                                                            ?.reset();
                                                        _formKey11.currentState
                                                            ?.reset();
                                                        _formKey12.currentState
                                                            ?.reset();
                                                        _formKey13.currentState
                                                            ?.reset();
                                                        if (selectedTypeE ==
                                                            'OTHER') {
                                                          _formKey10
                                                              .currentState
                                                              ?.reset();
                                                        }
                                                        isEncourageEdict =
                                                            false;
                                                      });
                                                    }
                                                  });
                                                } else {
                                                  setState(() {
                                                    bool isDuplicate = false;
                                                    for (var data
                                                        in encourageList) {
                                                      if (data['fullName'] ==
                                                          encourage[
                                                              'fullName']) {
                                                        isDuplicate = true;
                                                        break;
                                                      }
                                                    }

                                                    if (isDuplicate) {
                                                      showNoticeBarRed(
                                                          "accompany".tr +
                                                              "：" +
                                                              encourage[
                                                                  'fullName'] +
                                                              "alreadyExit".tr);
                                                    } else {
                                                      showNoticeBarGreen(
                                                          "accompany".tr +
                                                              "：" +
                                                              encourage[
                                                                  'fullName'] +
                                                              "addScuss".tr);
                                                      encourageList
                                                          .add(encourage);

                                                      certificateEController
                                                          .clear();
                                                      fullNameEController
                                                          .clear();
                                                      mobileEController.clear();
                                                      companyNameEController
                                                          .clear();
                                                      if (selectedTypeE ==
                                                          'OTHER') {
                                                        certificateNameEController
                                                            .clear();
                                                      }
                                                      if (kDebugMode) {
                                                        print("清空");
                                                      }
                                                      // 延时500毫秒后执行的代码
                                                      WidgetsBinding.instance
                                                          .addPostFrameCallback(
                                                              (_) {
                                                        // 在下一帧绘制后执行的代码
                                                        _formKey9.currentState
                                                            ?.reset();
                                                        _formKey11.currentState
                                                            ?.reset();
                                                        _formKey12.currentState
                                                            ?.reset();
                                                        _formKey13.currentState
                                                            ?.reset();
                                                        if (selectedTypeE ==
                                                            'OTHER') {
                                                          _formKey10
                                                              .currentState
                                                              ?.reset();
                                                        }
                                                      });
                                                      setState(() {});
                                                      // });
                                                    }
                                                  });
                                                }
                                              }
                                            },
                                            child: Text(
                                                isEncourageEdict
                                                    ? 'Edict'.tr
                                                    : 'ADD'.tr,
                                                style: TextStyle(
                                                    fontSize: 36.sp,
                                                    color: const Color.fromRGBO(
                                                        51, 119, 203, 1))),
                                          ),
                                        ),
                                        SizedBox(height: 50.h),
                                        SizedBox(
                                          width: 320.w,
                                          height: 75.h,
                                          child: ElevatedButton(
                                            style: ButtonStyle(
                                              backgroundColor:
                                                  MaterialStateProperty.all<
                                                          Color>(
                                                      const Color.fromRGBO(
                                                          51, 119, 203, 1)),
                                              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                                RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(10.0), // 调整圆角半径
                                                ),
                                              ),
                                            ),
                                            onPressed: () async {
                                              if (encourageList.isEmpty) {
                                                showNoticeBarRed(
                                                    "encourageListError".tr);
                                              } else {
                                                setState(() {
                                                  activeStep = 2;
                                                  title = "stepts_tv4".tr;
                                                });
                                              }
                                            },
                                            child: Text('nextStept'.tr,
                                                style: TextStyle(
                                                  fontSize: 36.sp,
                                                    color: const Color.fromRGBO(
                                                        255, 255, 255, 1.0)
                                                )),
                                          ),
                                        )
                                      ],
                                    ),
                                  )
                                ],
                              ),
                              SizedBox(
                                  width: boxWidth,
                                  child: Container(
                                    margin: EdgeInsets.only(left: 120.w),
                                    child: Wrap(
                                      spacing: 5.w,
                                      runSpacing: 10.h,
                                      children: List.generate(
                                          encourageList.length, (index) {
                                        return GestureDetector(
                                          onTap: () {
                                            if (kDebugMode) {
                                              print(index);
                                            }
                                            setState(() {
                                              isEncourageEdict = true;
                                              encourageEdictIndex = index;
                                              certificateEController.text =
                                                  encourageList[
                                                          encourageEdictIndex]
                                                      ['certificateNo'];
                                              fullNameEController.text =
                                                  encourageList[
                                                          encourageEdictIndex]
                                                      ['fullName'];
                                              mobileEController.text =
                                                  encourageList[
                                                          encourageEdictIndex]
                                                      ['mobile'];
                                              emailEController.text =
                                                  encourageList[
                                                          encourageEdictIndex]
                                                      ['email'];
                                              selectedTypeE = encourageList[
                                                      encourageEdictIndex]
                                                  ['certificateType'];
                                              if (selectedTypeE == 'OTHER') {
                                                certificateNameEController
                                                    .text = encourageList[
                                                        encourageEdictIndex]
                                                    ['certificateName'];
                                              }
                                            });
                                          },
                                          child: Container(
                                              width: itemLeftTitleWidth,
                                              height: 45.h,
                                              color: const Color.fromRGBO(
                                                  51, 119, 203, 0.2),
                                              child: Row(
                                                children: [
                                                  SizedBox(
                                                    width: 250.w,
                                                    height: 45.h,
                                                    child: Center(
                                                      child: Text(
                                                          encourageList[index]
                                                              ['fullName'],
                                                          style: TextStyle(
                                                              color: const Color
                                                                  .fromRGBO(
                                                                      51,
                                                                      119,
                                                                      203,
                                                                      1),
                                                              fontSize: 26.sp)),
                                                    ),
                                                  ),
                                                  GestureDetector(
                                                    onTap: () {
                                                      if (kDebugMode) {
                                                        print(index);
                                                      }
                                                      setState(() {
                                                        encourageList
                                                            .removeAt(index);
                                                      });
                                                    },
                                                    child: SizedBox(
                                                      width: 50.w,
                                                      height: 45.h,
                                                      child: Center(
                                                        child: Text("X",
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .white,
                                                                fontSize:
                                                                    26.sp)),
                                                      ),
                                                    ),
                                                  )
                                                ],
                                              )),
                                        );
                                      }),
                                    ),
                                  ))
                            ],
                          )),
                    if (activeStep == 2)
                      SizedBox(
                          width: boxWidth,
                          child: Column(
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  SizedBox(
                                    width: itemAllWidth,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(height: 20.h),
                                        SizedBox(
                                            width: itemWidth,
                                            height: inputHeight,
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: [
                                                SizedBox(
                                                  width: itemLeftWidth,
                                                  height: inputHeight,
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.end,
                                                    children: [
                                                      SizedBox(
                                                        width: 30.w,
                                                        child: requireIcon,
                                                      ),
                                                      IntrinsicWidth(
                                                        child: Align(
                                                          alignment: Alignment
                                                              .centerRight,
                                                          child: Text(
                                                            "visitorReason".tr,
                                                            textAlign:
                                                                TextAlign.right,
                                                            style: TextStyle(
                                                                fontSize: 36.sp,
                                                                color: const Color
                                                                    .fromRGBO(
                                                                        121,
                                                                        121,
                                                                        121,
                                                                        1)),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                SizedBox(
                                                    width: itemRightWidth,
                                                    height: inputHeight,
                                                    child: SizedBox(
                                                      width: itemRightWidth,
                                                      height: inputHeight,
                                                      child: DropdownButtonFormField<
                                                              String>(
                                                          focusNode:
                                                              visitReasonFocusNode,
                                                          value:
                                                              visitorReasonOption,
                                                          itemHeight:
                                                              inputHeight,
                                                          isExpanded: true,
                                                          iconSize: iconSize,
                                                          style: inputFontStyle,
                                                          hint: Text(
                                                              "visitorReasonError"
                                                                  .tr),
                                                          items:
                                                              visitorReasonOptions
                                                                  .map((dynamic
                                                                      option) {
                                                            return DropdownMenuItem<
                                                                String>(
                                                              value:
                                                                  option['id'],
                                                              child: Text(
                                                                  locale ==
                                                                          'zh-CN'
                                                                      ? option[
                                                                          'nameZh']
                                                                      : option[
                                                                          'nameEn'],
                                                                  style: TextStyle(
                                                                      color: const Color.fromRGBO(
                                                                          121,
                                                                          121,
                                                                          121,
                                                                          1),
                                                                      fontSize:
                                                                          32.sp)),
                                                            );
                                                          }).toList(),
                                                          onChanged: (String?
                                                              newValue) {
                                                            setState(() {
                                                              //选择拜访缘由
                                                              visitorReasonOption =
                                                                  newValue!;
                                                              getVisiToByReasonOption(
                                                                  visitorReasonOption);
                                                            });
                                                          },
                                                          decoration:
                                                              InputDecoration(
                                                            contentPadding:
                                                                EdgeInsets.symmetric(
                                                                    vertical:
                                                                        10.h,
                                                                    horizontal:
                                                                        10.w),
                                                            border: OutlineInputBorder(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            11.0.sp)),
                                                            // isDense: true, // 将isDense设置为true
                                                            errorStyle:
                                                                inputErrorFontStyle,
                                                          )),
                                                    ))
                                              ],
                                            )),
                                        Container(
                                          margin: EdgeInsets.only(
                                              left: fouritemLeftWidth),
                                          width: itemRightWidth,
                                          height: fourItemErrorContainer,
                                          child: showVisitReasonError &&
                                                  visitorReasonOption == null
                                              ? Text("visitorReasonError".tr,
                                                  style:
                                                      custommerErrorFontStyle)
                                              : null,
                                        ),
                                        SizedBox(
                                            width: itemWidth,
                                            height: inputHeight,
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: [
                                                SizedBox(
                                                  width: itemLeftWidth,
                                                  height: inputHeight,
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.end,
                                                    children: [
                                                      SizedBox(
                                                        width: 30.w,
                                                        child: requireIcon,
                                                      ),
                                                      IntrinsicWidth(
                                                        child: Align(
                                                          alignment: Alignment
                                                              .centerRight,
                                                          child: Text(
                                                            "visitTo".tr,
                                                            textAlign:
                                                                TextAlign.right,
                                                            style: TextStyle(
                                                                fontSize: 36.sp,
                                                                color: const Color
                                                                    .fromRGBO(
                                                                        121,
                                                                        121,
                                                                        121,
                                                                        1)),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                SizedBox(
                                                    width: itemRightWidth,
                                                    height: inputHeight,
                                                    child: SizedBox(
                                                        width: itemRightWidth,
                                                        height: inputHeight,
                                                        child: SizedBox(
                                                          width: 800.w,
                                                          height: inputHeight,
                                                          child: Autocomplete<
                                                              String>(
                                                            optionsBuilder:
                                                                (TextEditingValue
                                                                    textEditingValue) async {
                                                              if (textEditingValue
                                                                          .text
                                                                          .trim() ==
                                                                      '' ||
                                                                  textEditingValue
                                                                          .text
                                                                          .length <
                                                                      2) {
                                                                return [];
                                                              }
                                                              final Iterable<
                                                                      dynamic>?
                                                                  options =
                                                                  await _debouncedSearch(
                                                                      textEditingValue
                                                                          .text);
                                                              if (options ==
                                                                  null) {
                                                                return [];
                                                              }
                                                              return options.map(
                                                                  (option) =>
                                                                      jsonEncode(
                                                                          option));
                                                            },
                                                            //选择受访者
                                                            onSelected: (String
                                                                selection) {
                                                              setState(() {

                                                                visitToController
                                                                    .text = jsonDecode(
                                                                        selection)[
                                                                    'fullName'];
                                                                visitToId =
                                                                    jsonDecode(
                                                                            selection)[
                                                                        'userId'];
                                                                FocusScopeNode
                                                                    currentFocus =
                                                                    FocusScope.of(
                                                                        context);
                                                                if (!currentFocus
                                                                    .hasPrimaryFocus) {
                                                                  currentFocus
                                                                      .unfocus();
                                                                }
                                                                showVisitError =
                                                                    false;
                                                              });
                                                            },
                                                            fieldViewBuilder: (BuildContext
                                                                    context,
                                                                TextEditingController
                                                                    textEditingController,
                                                                FocusNode
                                                                    focusNode,
                                                                VoidCallback
                                                                    onFieldSubmitted) {
                                                              textEditingController
                                                                      .text =
                                                                  visitToController
                                                                      .text;
                                                              focusNode
                                                                  .addListener(
                                                                      () {
                                                                if (focusNode
                                                                    .hasFocus) {
                                                                  setState(() {
                                                                    showVisitError =
                                                                        true;
                                                                    endTimeChildController
                                                                        .closeEndTimeDialog();
                                                                  });
                                                                } else {}
                                                              });

                                                              return TextField(
                                                                controller:
                                                                    textEditingController,
                                                                focusNode:
                                                                    focusNode,
                                                                decoration:
                                                                    InputDecoration(
                                                                  contentPadding: EdgeInsets.symmetric(
                                                                      vertical:
                                                                          10.h,
                                                                      horizontal:
                                                                          10.w),
                                                                  border:
                                                                      OutlineInputBorder(
                                                                    borderSide:
                                                                        const BorderSide(
                                                                            color:
                                                                                Colors.grey),
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            11.0.sp),
                                                                  ),
                                                                  hintText:
                                                                      'visitToError'
                                                                          .tr,
                                                                ),
                                                                style:
                                                                    inputFontStyle,
                                                                onChanged:
                                                                    (value) {
                                                                  // onFieldSubmitted();
                                                                },
                                                              );
                                                            },
                                                            optionsViewBuilder: (BuildContext
                                                                    context,
                                                                AutocompleteOnSelected<
                                                                        String>
                                                                    onSelected,
                                                                Iterable<String>
                                                                    options) {
                                                              return Align(
                                                                alignment:
                                                                    Alignment
                                                                        .topLeft,
                                                                child: Material(
                                                                  elevation:
                                                                      4.0,
                                                                  child:
                                                                      SizedBox(
                                                                    width:
                                                                        700.0.w,
                                                                    // 自定义搜索结果的宽度
                                                                    child:
                                                                        ListView(
                                                                      padding:
                                                                          EdgeInsets
                                                                              .zero,
                                                                      shrinkWrap:
                                                                          true,
                                                                      children: options.map(
                                                                          (String
                                                                              option) {
                                                                        return ListTile(
                                                                          title:
                                                                              Text(
                                                                            jsonDecode(option)['fullName'],
                                                                            style:
                                                                                TextStyle(fontSize: 40.sp),
                                                                          ),
                                                                          onTap:
                                                                              () {
                                                                            onSelected(option);
                                                                          },
                                                                        );
                                                                      }).toList(),
                                                                    ),
                                                                  ),
                                                                ),
                                                              );
                                                            },
                                                          ),
                                                        )))
                                              ],
                                            )),
                                        Container(
                                          margin: EdgeInsets.only(
                                              left: fouritemLeftWidth),
                                          width: fouritemRightWidth,
                                          height: fourItemErrorContainer,
                                          child: showVisitError &&
                                                  visitToController.text
                                                          .trim() ==
                                                      ''
                                              ? Text("visitToError".tr,
                                                  style:
                                                      custommerErrorFontStyle)
                                              : null,
                                        ),
                                        SizedBox(
                                            width: itemWidth,
                                            height: inputHeight,
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: [
                                                SizedBox(
                                                  width: itemLeftWidth,
                                                  height: inputHeight,
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.end,
                                                    children: [
                                                      SizedBox(
                                                        width: 30.w,
                                                        child: requireIcon,
                                                      ),
                                                      IntrinsicWidth(
                                                        child: Align(
                                                          alignment: Alignment
                                                              .centerRight,
                                                          child: Text(
                                                            "endTime".tr,
                                                            textAlign:
                                                                TextAlign.right,
                                                            style: TextStyle(
                                                                fontSize: 36.sp,
                                                                color: const Color
                                                                    .fromRGBO(
                                                                        121,
                                                                        121,
                                                                        121,
                                                                        1)),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                SizedBox(
                                                  width: 700.w,
                                                  height: inputHeight,
                                                  child: TimeSelectPage(
                                                    controller:
                                                        endTimeEController,
                                                    controllers:
                                                        endTimeChildController,
                                                    onSelectedValue: (value) {
                                                      // 在这里对选中的值进行处理
                                                    },
                                                  ),
                                                )
                                              ],
                                            )),
                                        Container(
                                          margin: EdgeInsets.only(
                                              left: fouritemLeftWidth),
                                          width: fouritemRightWidth,
                                          height: fourItemErrorContainer,
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    width: 380.w,
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          width: 320.w,
                                          height: 75.h,
                                          margin: EdgeInsets.only(right: 20.w),
                                          child: ElevatedButton(
                                            style: ButtonStyle(
                                              backgroundColor:
                                                  MaterialStateProperty.all<
                                                      Color>(Colors.white),
                                              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                                RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(10.0),
                                                  side: const BorderSide(
                                                    color: Color.fromRGBO(
                                                        121, 121, 121, 1.0), // 设置边框颜色
                                                    width: 1.0, // 设置边框宽度
                                                  ),// 调整圆角半径
                                                ),
                                              ),
                                              elevation: MaterialStateProperty.all<double>(1.0),
                                            ),
                                            onPressed: () async {
                                              endTimeChildController
                                                  .closeEndTimeDialog();
                                              if (encourageList.isEmpty) {
                                                setState(() {
                                                  activeStep = 0;
                                                  title = "stepts_tv2".tr;
                                                });
                                              } else {
                                                setState(() {
                                                  activeStep = 1;
                                                  title = "stepts_tv3".tr;
                                                });
                                              }
                                            },
                                            child: Text('lastStept'.tr,
                                                style: TextStyle(
                                                    fontSize: 36.sp,
                                                    // ignore: prefer_const_constructors
                                                    color: Color.fromRGBO(
                                                        51, 119, 203, 1))),
                                          ),
                                        ),
                                        SizedBox(height: 50.h),
                                        SizedBox(
                                          width: 320.w,
                                          height: 75.h,
                                          child: ElevatedButton(
                                            style: ButtonStyle(
                                              backgroundColor:
                                                  MaterialStateProperty.all<
                                                          Color>(
                                                      const Color.fromRGBO(
                                                          51, 119, 203, 1)),
                                              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                                RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(10.0), // 调整圆角半径
                                                ),
                                              ),
                                            ),
                                            onPressed: () async {
                                              endTimeChildController
                                                  .closeEndTimeDialog();



                                              setState(() {
                                                if (visitToController.text
                                                        .trim() ==
                                                    '') {
                                                  showVisitError = true;
                                                }
                                                if (visitorReasonOption ==
                                                    null) {
                                                  showVisitReasonError = true;
                                                }
                                              });

                                              WidgetsBinding.instance
                                                  .addPostFrameCallback(
                                                      (_) async {
                                                    if (visitToController.text
                                                        .trim() ==
                                                        '' ||
                                                        visitorReasonOption ==
                                                            null) {
                                                      showNoticeBarRed(
                                                          "formError".tr);
                                                      return;
                                                    }
                                                    if (kDebugMode) {
                                                      print(adressIds);
                                                    }
                                                    if (kDebugMode) {
                                                      print(visitToId);
                                                    }
                                                    if (kDebugMode) {
                                                      print(getTodayTimestamps(
                                                            formatterTime(
                                                                getCurrentTime())));
                                                    }
                                                    if (kDebugMode) {
                                                      print(getTodayTimestamp(
                                                        endTimeEController.text));
                                                    }
                                                    if (kDebugMode) {
                                                      print(visitorReasonOption);
                                                    }

                                                    String timezone = "";
                                                    DateTime localDate = DateTime(
                                                      DateTime.now().year,
                                                      DateTime.now().month,
                                                      DateTime.now().day,
                                                      TimeOfDay.now().hour,
                                                      TimeOfDay.now().minute,
                                                    );

                                                    // 请求位置权限
                                                    Map<Permission,
                                                        PermissionStatus>
                                                    statuses = await [
                                                      Permission.location,
                                                    ].request();

                                                    // 检查权限状态
                                                    if (statuses[
                                                    Permission.location] ==
                                                        PermissionStatus.granted) {
                                                      timezone =
                                                      await FlutterNativeTimezone
                                                          .getLocalTimezone();
                                                      if (kDebugMode) {
                                                        print(
                                                          'Device timezone is: $timezone');
                                                      }
                                                    } else {
                                                      // 处理权限被拒绝的情况
                                                    }

                                                    SharedPreferences preferences =
                                                    await SharedPreferences.getInstance();
                                                  String? vipId= preferences.getString("vipId");
                                                    Map<String, dynamic> params = {
                                                      "floorId": adressIds[3],
                                                      "visitorTo": visitToId,
                                                      "startDateTimeStamp":
                                                      getTodayTimestamps(
                                                              formatterTime(
                                                                  getCurrentTime())),
                                                      "endDateTimeStamp":
                                                      getTodayTimestamp(
                                                          endTimeEController
                                                              .text),
                                                      "reason": visitorReasonOption,
                                                      "sourceType": "APPLET",
                                                      "timeZone": timezone,
                                                      "useVipChannel": true,
                                                      "vipChannelAuthorizer":vipId
                                                    };

                                                    List<dynamic> visitorList = [];
                                                    params['visitorList[0].position'] =
                                                        "";
                                                    params['visitorList[0].certificateNo'] =
                                                        certificateController.text;
                                                    params['visitorList[0].certificateType'] =
                                                        selectedType;
                                                    params['visitorList[0].fullName'] =
                                                        fullNameController.text;
                                                    params['visitorList[0].mobile'] =
                                                    (areaCode! +
                                                        mobileController.text)!;
                                                    params['visitorList[0].type'] =
                                                    'VISITOR';
                                                    params['visitorList[0].organization'] =
                                                        companyNameController.text;

                                                    if (selectedType == 'OTHER') {
                                                      params['visitorList[0].certificateDescription'] =
                                                          certificateNameController
                                                              .text;
                                                    }

                                                    if (encourageList.isNotEmpty) {
                                                      for (int i = 0;
                                                      i < encourageList.length;
                                                      i++) {
                                                        params['visitorList[${i + 1}].certificateNo'] =
                                                        encourageList[i]
                                                        ['certificateNo'];
                                                        params['visitorList[${i + 1}].certificateType'] =
                                                        encourageList[i]
                                                        ['certificateType'];
                                                        params['visitorList[${i + 1}].fullName'] =
                                                        encourageList[i]
                                                        ['fullName'];
                                                        params['visitorList[${i + 1}].mobile'] =
                                                        (areaCode2! +
                                                            encourageList[i]
                                                            ['mobile'])!;
                                                        params['visitorList[${i + 1}].organization'] =
                                                        encourageList[i]
                                                        ['companyName'];
                                                        params['visitorList[${i + 1}].type'] =
                                                        'ACCOMPANYING';
                                                        if (encourageList[i][
                                                        'certificateType'] ==
                                                            'OTHER') {
                                                          params['visitorList[${i + 1}].certificateDescription'] =
                                                          encourageList[i][
                                                          'certificateDescription'];
                                                        }
                                                      }
                                                    }

                                                    if (kDebugMode) {
                                                      print(params.toString());
                                                    }

                                                    dioFormData.FormData formData =
                                                    dioFormData.FormData
                                                        .fromMap(params);
                                                    dynamic result =
                                                    await TemporaryVisitorAPI
                                                        .applyTemporaryVisit(
                                                        formData);
                                                    if (result.code == '200') {
                                                      dynamic data=result.data;
                                                      if (kDebugMode) {
                                                        print("遍历签到,遍历访客");
                                                      }
                                                      if (kDebugMode) {
                                                        print(data['visitorList'].toString());
                                                      }
                                                      for(int e=0;e<data['visitorList'].length;e++){
                                                        Map params =
                                                        {
                                                          "type": 1,
                                                          "visitApplyId":data['visitorList'][e]['visitApplyId'],
                                                          "visitorCode":data['visitorList'][e]['visitorCode'],
                                                          "way": "APPLET"
                                                        };
                                                        dynamic result =await  InvitedVisitorAPI.checkInorOut(params);
                                                      }

                                                      setState(() async {
                                                          activeStep=3;
                                                          printData=data['visitorList'];
                                                          itemCount=data['visitorList'].length;
                                                          printDataOther['visitorTo']=data['visitorTo'];

                                                          int startDateTimeStamp = int.tryParse(data['startDateTimeStamp']) ?? 0;
                                                          String start = formatDate(
                                                              DateTime.fromMillisecondsSinceEpoch(startDateTimeStamp),
                                                              [yyyy, '-', mm, '-', dd, ' ', HH, ':', nn]);

                                                          int endDateTimeStamp = int.tryParse(data['endDateTimeStamp']) ?? 0;
                                                          String end = formatDate(
                                                              DateTime.fromMillisecondsSinceEpoch(endDateTimeStamp), [HH, ':', nn]);

                                                          printDataOther['startAndEnd']= '$start-$end';
                                                          itemKeys = List.generate(itemCount, (_) => GlobalKey());
                                                      });
                                                    }
                                                  });
                                            },
                                            child: Text('nextStept'.tr,
                                                style: TextStyle(
                                                  fontSize: 36.sp,
                                                    color: const Color.fromRGBO(255, 255, 255, 1)
                                                )),
                                          ),
                                        )
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            ],
                          )),
                    if (activeStep == 3)
                      Container(
                        width: 1500.w,
                        margin: EdgeInsets.only(left: 50.w),
                        height: 650.h,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SizedBox(
                              width: 1000.w,
                              height: 650.h,
                              child: Swiper(
                                itemCount: itemCount ?? 0, // 如果itemCount不为null，则使用itemCount的值，否则使用0
                                itemBuilder: (context, index) {
                                  return SizedBox(
                                    width: 420.w,
                                    height: 650.h,
                                    child: Align(
                                      alignment: Alignment.center,
                                      child: RepaintBoundary(
                                        key: itemKeys.length > index ? itemKeys[index] : GlobalKey(), // 根据itemKeys长度获取对应的GlobalKey，如果长度不足则使用新的GlobalKey
                                        child: Container(
                                          width: 420.w,
                                          height: 650.h,
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                              color: const Color.fromRGBO(
                                                  121, 121, 121, 0.4),
                                              width: 2.0,
                                            ),
                                            borderRadius:
                                            BorderRadius.circular(11.0.sp),
                                          ),
                                          child: Column(
                                            children: [
                                              SizedBox(height: 35.h),
                                              // 其他子部件...
                                              SizedBox(
                                                  width: 500.w,
                                                  height: 60.h,
                                                  child: Center(
                                                    child: Center(
                                                      child: Text(
                                                        "visitPass".tr,
                                                        style: TextStyle(
                                                            fontSize: 36.sp,
                                                            color: const Color.fromRGBO(
                                                                0, 0, 0, 1)),
                                                      ),
                                                    ),
                                                  )),
                                              SizedBox(
                                                width: 500.0.w,
                                                height: 2.0.h,
                                                child: Align(
                                                  alignment: Alignment.centerLeft,
                                                  child: Container(
                                                    width: 500.0.w,
                                                    height: 2.0.h,
                                                    color: const Color.fromRGBO(
                                                        121, 121, 121, 1),
                                                  ),
                                                ),
                                              ),
                                              SizedBox(
                                                  width: 500.w,
                                                  height: 60.h,
                                                  child: Center(
                                                    child: Center(
                                                      child: Text(
                                                        printData[index]['fullName'],
                                                        style: TextStyle(
                                                          fontSize: 42.sp,
                                                          color: const Color.fromRGBO(
                                                              0, 0, 0, 1),
                                                          fontWeight:
                                                          FontWeight.bold,
                                                        ),
                                                      ),
                                                    ),
                                                  )),
                                              SizedBox(
                                                  width: 500.w,
                                                  height: 50.h,
                                                  child: Center(
                                                    child: Center(
                                                      child: Text(
                                                        printData[index]['organization'],
                                                        style: TextStyle(
                                                            fontSize: 26.sp,
                                                            color: const Color.fromRGBO(
                                                                0, 0, 0, 1)),
                                                      ),
                                                    ),
                                                  )),
                                              SizedBox(
                                                  width: 500.w,
                                                  height: 50.h,
                                                  child: Center(
                                                    child: Center(
                                                      child: Text(
                                                        printDataOther['startAndEnd'],
                                                        style: TextStyle(
                                                            fontSize: 26.sp,
                                                            color: const Color.fromRGBO(
                                                                0, 0, 0, 1)),
                                                      ),
                                                    ),
                                                  )),
                                              SizedBox(
                                                  width: 500.w,
                                                  height: 50.h,
                                                  child: Center(
                                                    child: Center(
                                                      child: Text(
                                                        "visitTo".tr+printDataOther['visitorTo']['fullName'],
                                                        style: TextStyle(
                                                          fontSize: 26.sp,
                                                          color: const Color.fromRGBO(
                                                              0, 0, 0, 1),
                                                          fontWeight:
                                                          FontWeight.bold,
                                                        ),
                                                      ),
                                                    ),
                                                  )),
                                              SizedBox(
                                                height: 26.h,
                                              ),
                                              SizedBox(
                                                  width: 225.w,
                                                  height: 275.h,
                                                  child: Column(
                                                    children: [
                                                      QrImageView(
                                                        data: jsonEncode({
                                                          "visitorCode":printData[index]['visitorCode'],
                                                          "visitId":printData[index]['visitApplyId']
                                                        }),
                                                        // 设置要生成的文本或链接
                                                        version: QrVersions.auto,
                                                        size: 225.0.w,
                                                        padding:
                                                        EdgeInsets.all(0.w),
                                                      ),
                                                      Container(
                                                        width: 220.w,
                                                        height: 40.h,
                                                        margin: EdgeInsets.only(top: 10.h),
                                                        child: Center(
                                                          child: Text(printData[index]['visitorCode'],
                                                              style: TextStyle(
                                                                  color: const Color
                                                                      .fromRGBO(
                                                                      0,
                                                                      0,
                                                                      0,
                                                                      1),
                                                                  fontStyle:
                                                                  FontStyle
                                                                      .italic,
                                                                  fontSize:
                                                                  26.sp)),
                                                        ),
                                                      )
                                                    ],
                                                  )),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                                // 其他属性...
                                autoplay: false,
                                itemHeight: 650.h,
                                itemWidth: 400.w,
                                onIndexChanged: (index){
                                  if (kDebugMode) {
                                    print(index);
                                  }
                                    swiperIndexee=index;
                                },
                                //引起下标变化的监听
                                onTap: (index) {

                                },
                                //点击轮播时调用
                                duration: 1000,
                                //切换时的动画时间
                                autoplayDelay: 2000,
                                //自动播放间隔毫秒数.
                                autoplayDisableOnInteraction: false,
                                // loop: true,
                                //是否无限轮播
                                scrollDirection: Axis.horizontal,
                                //滚动方向
                                index: 0,
                                //初始下标位置
                                scale: 0.5,
                                //轮播图之间的间距
                                viewportFraction: 1,
                                //当前视窗比例，小于1时就会在屏幕内，可以看见旁边的轮播图
                                indicatorLayout: PageIndicatorLayout.COLOR,
                                pagination: const SwiperPagination(),
                                //底部指示器
                                control: const SwiperControl(
                                  iconNext: Icons.arrow_forward_ios,
                                  iconPrevious: Icons.arrow_back_ios,
                                ), //左右箭头
                              ),
                            ),
                            SizedBox(
                                width: 400.w,
                                height: 600.h,
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        width: 320.w,
                                        height: 75.h,
                                        margin: EdgeInsets.only(right: 20.w),
                                        child: ElevatedButton(
                                          style: ButtonStyle(
                                            backgroundColor:
                                                MaterialStateProperty.all<
                                                    Color>(Colors.white),
                                            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                              RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(10.0),
                                                side: const BorderSide(
                                                  color: Color.fromRGBO(
                                                      121, 121, 121, 1.0), // 设置边框颜色
                                                  width: 1.0, // 设置边框宽度
                                                ),// 调整圆角半径
                                              ),
                                            ),
                                            elevation: MaterialStateProperty.all<double>(1.0),
                                          ),
                                          onPressed: () async {
                                            setState(() {
                                              activeStep = 2;
                                              title = "stepts_tv3".tr;
                                            });
                                          },
                                          child: Text('lastStept'.tr,
                                              style: TextStyle(
                                                  fontSize: 36.sp,
                                                  color: const Color.fromRGBO(
                                                      51, 119, 203, 1))),
                                        ),
                                      ),
                                      SizedBox(height: 50.h),
                                      SizedBox(
                                        width: 320.w,
                                        height: 75.h,
                                        child: ElevatedButton(
                                          style: ButtonStyle(
                                            backgroundColor:
                                                MaterialStateProperty
                                                    .all<Color>(const Color.fromRGBO(
                                                        51, 119, 203, 1)),
                                            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                              RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(10.0), // 调整圆角半径
                                              ),
                                            ),
                                          ),
                                          onPressed: () async {
                                            final boundary = itemKeys[swiperIndexee]
                                                    .currentContext
                                                    ?.findRenderObject()
                                                as RenderRepaintBoundary?;
                                            if (kDebugMode) {
                                              print("图片数据流");
                                            }
                                            if (kDebugMode) {
                                              print(boundary);
                                            }
                                            if (boundary != null) {
                                              final image =
                                                  await boundary.toImage();
                                              ByteData? byteData =
                                                  await image.toByteData(
                                                      format:
                                                          ImageByteFormat.png);
                                              Uint8List? bytes = byteData
                                                  ?.buffer
                                                  .asUint8List();

                                              if (bytes != null) {
                                                // 图片数据生成成功，用法在下面
                                                EasyLoading.show(
                                                    status: 'loading...');
                                                var message =
                                                    await _methodPrintChannel
                                                        .invokeMethod(
                                                            'sendPrintByBitmap',
                                                            {
                                                      'imgBitMap': bytes
                                                    });
                                                EasyLoading.dismiss();
                                                if (kDebugMode) {
                                                  print(message);
                                                }
                                                dynamic jsonData =
                                                    jsonDecode(message);
                                                if (jsonData['code'] == 200) {

                                                }
                                              }
                                            }
                                          },
                                          child: Text('print'.tr,
                                              style: TextStyle(
                                                fontSize: 36.sp,
                                                  color: const Color.fromRGBO(
                                                      255, 255, 255, 1.0)
                                              )),
                                        ),
                                      )
                                    ],
                                  ),
                                ))
                          ],
                        ),
                      )
                  ],
                )
              ],
            ),
          )))),
    );
  }
}

// _Debounceable<S, T> 是一个函数类型别名，接受一个类型为 T 的参数，并返回一个 Future<S?> 类型的结果。
typedef _Debounceable<S, T> = Future<S?> Function(T parameter);

_Debounceable<S, T> _debounce<S, T>(_Debounceable<S?, T> function) {
  _DebounceTimer? debounceTimer;

  return (T parameter) async {
    if (debounceTimer != null && !debounceTimer!.isCompleted) {
      debounceTimer!.cancel();
    }
    debounceTimer = _DebounceTimer();
    try {
      await debounceTimer!.future;
    } catch (error) {
      if (error is _CancelException) {
        return null;
      }
      rethrow;
    }
    return function(parameter);
  };
}

// A wrapper around Timer used for debouncing.
class _DebounceTimer {
  static const Duration debounceDuration = Duration(milliseconds: 1000);

  _DebounceTimer() {
    _timer = Timer(debounceDuration, _onComplete);
  }

  late final Timer _timer;
  final Completer<void> _completer = Completer<void>();

  void _onComplete() {
    _completer.complete();
  }

  Future<void> get future => _completer.future;

  bool get isCompleted => _completer.isCompleted;

  void cancel() {
    _timer.cancel();
    _completer.completeError(const _CancelException());
  }
}

// An exception indicating that the timer was canceled.
class _CancelException implements Exception {
  const _CancelException();
}
