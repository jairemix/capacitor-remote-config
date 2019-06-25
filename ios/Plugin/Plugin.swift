import Foundation
import Capacitor
import FirebaseRemoteConfig

/**
 * Please read the Capacitor iOS Plugin Development Guide
 * here: https://capacitor.ionicframework.com/docs/plugins/ios
 */
@objc(RemoteConfigPlugin)
public class RemoteConfigPlugin: CAPPlugin {
  
  let remoteConfig = RemoteConfig.remoteConfig();
    
  @objc func fetch(_ call: CAPPluginCall) {
    let expirationDuration = call.getDouble("expirationDuration");
    
    
    let completionHandler = {(status: RemoteConfigFetchStatus, error: Error?) in
      let statusString = self.statusToString(status);
      if (error == nil) {
        call.success([
          "status": statusString
        ]);
      } else {
        call.error(error!.localizedDescription, error!);
      }
    };
    
    if let expirationDuration = expirationDuration {
      print("[CapacitorRemoteConfig] fetch with expirationDuration: " + expirationDuration.description);
      self.remoteConfig.fetch(withExpirationDuration: expirationDuration, completionHandler: completionHandler);
    } else {
      self.remoteConfig.fetch(completionHandler: completionHandler);
    }
  }
  
  @objc func activateFetched(_ call: CAPPluginCall) {
    let activated = self.remoteConfig.activateFetched();
    call.success([
      "activated": activated
    ]);
  }
  
  @objc func getStrings(_ call: CAPPluginCall) {
    let keys = call.getArray("keys", String.self);
//    print("[CapacitorRemoteConfig] getStrings. keys: " + keys.debugDescription);
    
    if (keys == nil || keys!.count == 0) {
      call.error("[GET_STRINGS] NO_KEYS")
      return;
    }
    
    let values = keys!.map({ (key: String) -> String in
      let value = self.remoteConfig.configValue(forKey: key);
      return value.stringValue ?? "";
    });
    
    call.success([
      "values": values
    ]);
    
  }
  
  @objc func getLastFetchStatus(_ call: CAPPluginCall) {
    let statusString = self.statusToString(remoteConfig.lastFetchStatus);
    call.success([
      "status": statusString
    ]);
  }
  
  private func statusToString(_ status: RemoteConfigFetchStatus) -> String {
    switch (status) {
      case RemoteConfigFetchStatus.noFetchYet: return "noFetchYet";
      case RemoteConfigFetchStatus.success: return "success";
      case RemoteConfigFetchStatus.throttled: return "throttled";
      case RemoteConfigFetchStatus.failure: return "failure";
      default: return "";
    }
  }
  
  @objc func getLastFetchTime(_ call: CAPPluginCall) {
    let time = self.remoteConfig.lastFetchTime;
    if let time = time {
      let dateFormatter = ISO8601DateFormatter();
      dateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds];
      let dateString = dateFormatter.string(from: time);
      call.success([
        "lastFetchTime": dateString
      ]);
    } else {
      call.success([:]);
    }
  }

}
