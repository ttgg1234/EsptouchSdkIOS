package com.ibreezee.demo;

import android.Manifest;
import android.annotation.SuppressLint;
import android.app.ProgressDialog;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.content.pm.PackageManager;
import android.location.LocationManager;
import android.net.ConnectivityManager;
import android.net.NetworkInfo;
import android.net.wifi.WifiInfo;
import android.net.wifi.WifiManager;
import android.os.AsyncTask;
import android.os.Build;
import android.os.Bundle;
import android.os.Handler;
import android.os.Looper;
import android.os.Message;
import android.text.method.ScrollingMovementMethod;
import android.view.View;
import android.widget.EditText;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.appcompat.app.AlertDialog;
import androidx.core.app.ActivityCompat;
import androidx.core.content.ContextCompat;
import androidx.fragment.app.FragmentActivity;

import com.espressif.iot.esptouch.EsptouchTask;
import com.espressif.iot.esptouch.IEsptouchListener;
import com.espressif.iot.esptouch.IEsptouchResult;
import com.espressif.iot.esptouch.IEsptouchTask;
import com.espressif.iot.esptouch.util.EspNetUtil;

import java.lang.ref.WeakReference;
import java.util.List;

public class MainActivity extends FragmentActivity {
    private IEsptouchTask mWifiTask;
    private EsptouchAsyncTask mTask;
    private TextView tv_logo;
    private EditText et_wifi_name, et_wifi_password;
    private final StringBuffer stringBuffer = new StringBuffer();
    private WifiManager wifiManager;
    private WifiInfo wifiInfo;
    private String bassId = "";
    private static final int REQUEST_PERMISSION = 0x01;
    private ProgressDialog progressDialog;
    @SuppressLint("HandlerLeak")
    private Handler mHandler = new Handler(Looper.getMainLooper()) {
        @Override
        public void handleMessage(@NonNull Message msg) {
            super.handleMessage(msg);
            switch (msg.what) {
                case 110://正在进行WIFI配置
                    stringBuffer.append("正在进行WIFI配置").append("\n");
                    tv_logo.setText(stringBuffer.toString());
                    break;
                case 111://WIFI配置成功
                    stringBuffer.append("WIFI配置成功").append("\n");
                    tv_logo.setText(stringBuffer.toString());
                    progressDialog.dismiss();
                    break;
                case 510://WIFI配置超时
                    stringBuffer.append("WIFI配置超时").append("\n");
                    tv_logo.setText(stringBuffer.toString());
                    progressDialog.dismiss();
                    break;
            }
        }
    };

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);
        initProgressDialog();
        initView();
        wifiInit();
    }

    /**
     * 初始化View
     */
    private void initView() {
        tv_logo = findViewById(R.id.tv_logo);
        et_wifi_name = findViewById(R.id.et_wifi_name);
        et_wifi_password = findViewById(R.id.et_wifi_password);
        tv_logo.setMovementMethod(new ScrollingMovementMethod());
        findViewById(R.id.btn_setting).setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                if (et_wifi_name.getText().toString().isEmpty() || et_wifi_password.getText().toString().isEmpty())
                    return;
                //配网
                toWifiConfig(et_wifi_name.getText().toString(), et_wifi_password.getText().toString());
            }
        });
    }

    private void initProgressDialog() {
        progressDialog = new ProgressDialog(this);
        progressDialog.setMessage("加载中...");
        progressDialog.setCancelable(false); // 是否允许用户手动取消
    }


    /**
     * WiFi初始化
     */
    private void wifiInit() {
        stringBuffer.append("Wifi Init...").append("\n");
        tv_logo.setText(stringBuffer.toString());
        if (isWifi(this)) {
            if (Build.VERSION.SDK_INT >= 29) { // Android 10+
                if (ContextCompat.checkSelfPermission(this, Manifest.permission.ACCESS_FINE_LOCATION)
                        != PackageManager.PERMISSION_GRANTED) {
                    String[] permissions = {
                            Manifest.permission.ACCESS_FINE_LOCATION
                    };
                    ActivityCompat.requestPermissions(this, permissions, REQUEST_PERMISSION);
                } else {
                    registerBroadcastReceiver();
                }
            } else if (Build.VERSION.SDK_INT >= 28) {
                if (ContextCompat.checkSelfPermission(this, Manifest.permission.ACCESS_COARSE_LOCATION)
                        != PackageManager.PERMISSION_GRANTED) {
                    String[] permissions = {
                            Manifest.permission.ACCESS_COARSE_LOCATION
                    };
                    ActivityCompat.requestPermissions(this, permissions, REQUEST_PERMISSION);
                } else {
                    registerBroadcastReceiver();
                }
            } else {
                registerBroadcastReceiver();
            }
            refreshWifiName();
        } else {
            stringBuffer.append("当前设备没有连接Wifi").append("\n");
            tv_logo.setText(stringBuffer.toString());
        }
    }


    /**
     * 注册Wifi变化广播
     */
    private void registerBroadcastReceiver() {
        IntentFilter filter = new IntentFilter(WifiManager.NETWORK_STATE_CHANGED_ACTION);
        if (Build.VERSION.SDK_INT >= 28) {
            filter.addAction(LocationManager.PROVIDERS_CHANGED_ACTION);
        }
        registerReceiver(mReceiver, filter);
    }

    /**
     * 获取Wifi名称
     */
    private void refreshWifiName() {
        if (null == wifiManager)
            wifiManager = (WifiManager) this.getApplicationContext().getSystemService(WIFI_SERVICE);
        if (null != wifiManager) wifiInfo = wifiManager.getConnectionInfo();
        if (null != wifiInfo) {
            String connectWifiSsid = wifiInfo.getSSID();
            stringBuffer.append("currentWifiSsid---->").append(connectWifiSsid).append("\n");
            tv_logo.setText(stringBuffer.toString());
            if (!connectWifiSsid.isEmpty()) {
                String s1 = connectWifiSsid.substring(1, connectWifiSsid.length() - 1);//SSID默认有双引号
                if (!"unknown ssid".equals(s1)) {
                    stringBuffer.append("Wifi Name---->").append(s1).append("\n");
                    tv_logo.setText(stringBuffer.toString());
                }
            }
        }
    }

    /**
     * 连接WiFi的状态
     *
     * @param mContext 上下文
     * @return 是否连接了Wifi
     */
    private static boolean isWifi(Context mContext) {
        ConnectivityManager connectivityManager = (ConnectivityManager) mContext.getSystemService(Context.CONNECTIVITY_SERVICE);
        NetworkInfo activeNetInfo = connectivityManager.getActiveNetworkInfo();
        return activeNetInfo != null && activeNetInfo.getType() == ConnectivityManager.TYPE_WIFI;
    }


    /**
     * Wifi配网
     *
     * @param wifiName     Wifi名称
     * @param wiFiPassWord Wifi密码
     */
    private void toWifiConfig(String wifiName, String wiFiPassWord) {
        progressDialog.show();
        byte[] ssid = ByteUtil.getBytesByString(wifiName);
        byte[] password = ByteUtil.getBytesByString(wiFiPassWord);
        byte[] bssid = EspNetUtil.parseBssid2bytes(bassId);
        byte[] deviceCount = "1".getBytes();
        byte[] broadcast = {(byte) 0};

        if (mTask != null) {
            mTask.cancelWifiSetting();
        }
        mTask = new EsptouchAsyncTask(this);
        mTask.execute(ssid, bssid, password, deviceCount, broadcast);
    }


    /**
     * Wifi变化广播
     */
    private final BroadcastReceiver mReceiver = new BroadcastReceiver() {
        @Override
        public void onReceive(Context context, Intent intent) {
            String action = intent.getAction();
            if (action == null) {
                return;
            }
            WifiManager wifiManager = (WifiManager) context.getApplicationContext().getSystemService(WIFI_SERVICE);
            assert wifiManager != null;
            switch (action) {
                case WifiManager.NETWORK_STATE_CHANGED_ACTION:
                    WifiInfo wifiInfo;
                    if (intent.hasExtra(WifiManager.EXTRA_WIFI_INFO)) {
                        wifiInfo = intent.getParcelableExtra(WifiManager.EXTRA_WIFI_INFO);
                    } else {
                        wifiInfo = wifiManager.getConnectionInfo();
                    }
                    onWifiChanged(wifiInfo);
                    break;
                case LocationManager.PROVIDERS_CHANGED_ACTION:
                    onWifiChanged(wifiManager.getConnectionInfo());
                    break;
            }
        }
    };

    private void onWifiChanged(WifiInfo info) {
        if (info == null) {
            et_wifi_name.setText("");
            bassId = "";
            if (mTask != null) {
                mTask.cancelWifiSetting();
                mTask = null;
                new AlertDialog.Builder(MainActivity.this)
                        .setMessage("Wifi有变化")
                        .setNegativeButton(android.R.string.cancel, null)
                        .show();
            }
        } else {
            String ssid = info.getSSID();
            if (ssid.startsWith("\"") && ssid.endsWith("\"")) {
                ssid = ssid.substring(1, ssid.length() - 1);
            }
            et_wifi_name.setText(ssid);
            et_wifi_name.setTag(ByteUtil.getBytesByString(ssid));
            byte[] ssidOriginalData = EspUtils.getOriginalSsidBytes(info);
            et_wifi_name.setTag(ssidOriginalData);
            bassId = info.getBSSID();
            stringBuffer.append("bassid---->").append(bassId).append("\n");
            tv_logo.setText(stringBuffer.toString());
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
                int frequence = info.getFrequency();
                if (frequence > 4900 && frequence < 5900) {
                    // Connected 5G wifi. Device does not support 5G
                    stringBuffer.append("Connected 5G wifi. Device does not support 5G").append("\n");
                    tv_logo.setText(stringBuffer.toString());
                }
            }
        }
    }

    /**
     * 配网Task
     */
    @SuppressLint("StaticFieldLeak")
    private class EsptouchAsyncTask extends AsyncTask<byte[], Void, List<IEsptouchResult>> {
        private final WeakReference<MainActivity> mActivity;
        private final Object mLock = new Object();

        EsptouchAsyncTask(MainActivity activity) {
            mActivity = new WeakReference<>(activity);
        }

        void cancelWifiSetting() {
            cancel(true);
            //            timeOutFail();
            if (mWifiTask != null) {
                mWifiTask.interrupt();
            }
        }

        @Override
        protected void onPreExecute() {
            mHandler.sendEmptyMessage(110);
        }

        @Override
        protected List<IEsptouchResult> doInBackground(byte[]... params) {
            MainActivity activity = mActivity.get();
            int taskResultCount;
            synchronized (mLock) {
                byte[] apSsid = params[0];
                byte[] apBssid = params[1];
                byte[] apPassword = params[2];
                byte[] deviceCountData = params[3];
                byte[] broadcastData = params[4];
                taskResultCount = deviceCountData.length == 0 ? -1 : Integer.parseInt(new String(deviceCountData));
                Context context = activity.getApplicationContext();
                mWifiTask = new EsptouchTask(apSsid, apBssid, apPassword, context);
                mWifiTask.setPackageBroadcast(broadcastData[0] == 1);
                mWifiTask.setEsptouchListener(activity.myListener);
            }
            return mWifiTask.executeForResults(taskResultCount);
        }


        @Override
        protected void onPostExecute(List<IEsptouchResult> result) {
            MainActivity activity = mActivity.get();
            if (result == null) {
                mHandler.sendEmptyMessage(6);
                return;
            }
            IEsptouchResult firstResult = result.get(0);
            if (!firstResult.isCancelled()) {
                if (firstResult.isSuc()) {
                    //check whether the esptouch task is executed suc

                } else {
                    mHandler.sendEmptyMessage(510);
                }

            }

            activity.mTask = null;
        }
    }

    private final IEsptouchListener myListener = this::onWifiResultAddedPerform;


    //WIFI配置成功的回调
    private void onWifiResultAddedPerform(final IEsptouchResult result) {
        //WiFiConfig配置成功
        mHandler.sendEmptyMessage(111);
    }
}