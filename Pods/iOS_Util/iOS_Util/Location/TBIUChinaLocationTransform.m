//
// Created by <a href="mailto:wentong@taobao.com">文通</a> on 13-6-16 上午9:14.
//


#import "TBIUChinaLocationTransform.h"


static double pi = 3.14159265358979324;

static double a = 6378245.0;

static double ee = 0.00669342162296594323;

static bool outOfChina(CLLocationCoordinate2D coordinate2D) {
    if (coordinate2D.longitude < 72.004 || coordinate2D.longitude > 137.8347)
        return true;
    if (coordinate2D.latitude < 0.8293 || coordinate2D.latitude > 55.8271)
        return true;
    return false;
}

static double transformLat(double x, double y) {
    double ret = -100.0 + 2.0 * x + 3.0 * y + 0.2 * y * y + 0.1 * x * y + 0.2 * sqrt(fabs(x));
    ret += (20.0 * sin(6.0 * x * pi) + 20.0 * sin(2.0 * x * pi)) * 2.0 / 3.0;
    ret += (20.0 * sin(y * pi) + 40.0 * sin(y / 3.0 * pi)) * 2.0 / 3.0;
    ret += (160.0 * sin(y / 12.0 * pi) + 320 * sin(y * pi / 30.0)) * 2.0 / 3.0;
    return ret;
}

static double transformLon(double x, double y) {
    double ret = 300.0 + x + 2.0 * y + 0.1 * x * x + 0.1 * x * y + 0.1 * sqrt(fabs(x));
    ret += (20.0 * sin(6.0 * x * pi) + 20.0 * sin(2.0 * x * pi)) * 2.0 / 3.0;
    ret += (20.0 * sin(x * pi) + 40.0 * sin(x / 3.0 * pi)) * 2.0 / 3.0;
    ret += (150.0 * sin(x / 12.0 * pi) + 300.0 * sin(x / 30.0 * pi)) * 2.0 / 3.0;
    return ret;
}

inline CLLocationCoordinate2D transformChinaLocation(CLLocationCoordinate2D coordinate2D) {
    if (outOfChina(coordinate2D)) {
        return coordinate2D;
    }
    double dLat = transformLat(coordinate2D.longitude - 105.0, coordinate2D.latitude - 35.0);
    double dLon = transformLon(coordinate2D.longitude - 105.0, coordinate2D.latitude - 35.0);
    double radLat = coordinate2D.latitude / 180.0 * pi;
    double magic = sin(radLat);
    magic = 1 - ee * magic * magic;
    double sqrtMagic = sqrt(magic);
    dLat = (dLat * 180.0) / ((a * (1 - ee)) / (magic * sqrtMagic) * pi);
    dLon = (dLon * 180.0) / (a / sqrtMagic * cos(radLat) * pi);

    return CLLocationCoordinate2DMake(coordinate2D.latitude + dLat, coordinate2D.longitude + dLon);
}

inline void transformChinaLocationNoCopy(CLLocationCoordinate2D *coordinate2D) {
    if (!coordinate2D) {
        return;
    }
    CLLocationCoordinate2D r = transformChinaLocation(*coordinate2D);
    coordinate2D->longitude = r.longitude;
    coordinate2D->latitude = r.latitude;
}