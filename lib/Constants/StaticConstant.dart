import 'dart:ui';

import '../Components/Metal.dart';


class StaticUrl {
  static const String baseUrlS = "https://www.digicat.in/";
  static const String loginUrl = "${baseUrlS}webroot/RiteshApi/erp.php";
  static const String metalUrl = "${baseUrlS}api/webservices/erp_metal.json";
  static const String itemUrl = "${baseUrlS}api/webservices/erp_item.json";
  static const String processUrl = "${baseUrlS}api/webservices/erp_process.json";
  static const String productListUrl = "${baseUrlS}api/webservices/erp_wip_list.json";
}

class StaticColor {
  static const Color themeColor = Color(0xFF4C5564);
  static const Color themeColorLight = Color(0x804C5564);
  static const Color themeColor1 = Color(0xFF123456);
  static const Color addToCartColor = Color(0xFFA5A8AE);
  static const Color lightGrey = Color(0xFFD8D8D8);
  static const Color lightGreen = Color(0XFF39B8B5);
  static const Color lightYellow = Color(0XFF7E4B00);
  static const Color yellowDark = Color(0XFF7E4B00);
}

class StaticConstant {
  // Static constants

  static const String tagUserEmailIdForLogin = "tagUserEmailIdForLogin";
  static const String tagUserPasswordForLogin = "tagUserPasswordForLogin";

  static const String userToken = "UserToken";
  static const String userId = "userId";
  static const String userDetails = "UserDetails";
  static const String userData = "UserData";
  static const String scanByProductID = "Product ID";
  static const String scanBySKU = "SKU";

  static const String rfidASCII = "ASCII";
  static const String rfidHEXA = "HEXA";
  static const String constYes = "Yes";
  static const String constNo = "No";

  static const String tagPriceStatus = "PriceStatus";
  static const String tagLabourType = "LabourType";
  static const String tagCostPriceStatus = "CostPriceStatus";
  static const String tagDecimalPlaces = "DecimalPlaces";
  static const String tagCurrencyCode = "CurrencyCode";
  static const String tagExchangeRate = "ExchangeRate";
  static const String tagScanBy = "ScanBy";
  static const String tagRFID = "RFID";
  static const String tagActiveMultiplier = "ActiveMultiplier";
  static const String tagMultiplierCount = "MultiplierCount";
  static const String tagDivideCount = "DivideCount";
  static const String tagRfidName = "RFIDNAME";
  static const String tagRfidReference = "RFIDREFERENCE";
  static const String tagActivePricingWithRates = "ActivePricingWithRates";

  static const String tagAddedCard = "AddedCard";
  static const String tagPriceGrmList = "PriceGrmList";
  static const String tagPrasanBasisList = "PrasanBasisList";
  static const String tagRfidRECONCILIATION = "RfidRECONCILIATION";
}

class StaticData {
  static String userId = "";
  static String unique_id = "";
  static String tagPriceGrmListStr = "";
  static String selectedLabourType = "";
  static bool showPriceStatus = true;
  static bool LabourTypeStr = true;
  static bool showCostPriceStatus = true;
  static int showDecimalPlaces = 0;
  static String showCurrencyCode = "Rs";
  static double showExchangeRate = 1.0;
  static String showScanBy = StaticConstant.scanByProductID; //
  static String showRFID = StaticConstant.rfidASCII; //
  static String showActiveMultiplier = StaticConstant.constYes; //
  static String showActiveCostringSetting = StaticConstant.constYes; //
  static double showMultiplierCount = 1.0;
  static double showDivideCount = 0.0;
}
