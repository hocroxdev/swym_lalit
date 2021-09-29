//
//  AnalatycsConstants.swift
//  SYWM
//
//  Created by Arun J on 14/12/20.
//  Copyright © 2020 Maninder Singh. All rights reserved.
//

import Foundation

public struct FirebaseParam {
    static let  IS_POOL_SPONSORED = "sponsored_pool"
    static let  POOL_NAME = "pool_name"
    static let  POOL_LOCATION = "pool_loc"
    static let  POOL_DURATION = "pool_duration"
    
    static let  GENDER = "gender"
    static let  ABOUT_ME = "about_me"
    static let  HEIGHT = "height"
    static let  AGE = "age"
    
    static let  SIGN_UP_EMAIL_INCLUDED = "email_in_sign_up"
    static let  SIGN_UP_PHONE_INCLUDED = "phone_in_sign_up"
    static let  SIGN_UP_USING = "sign_up_using"
    static let  LOGIN_USING = "login_using"
    
    static let  POOL_ID = "pool_id"
    
    static let  FROM_ACTIVITY = "from_activity"
    static let  REASON = "reason"
    
    static let  ACTION = "action"
    
    static let  MATE_PREF = "like_pref"
    static let  AGE_RANGE = "age_range"
    static let  MATCH_NOTI = "match_noti"
    static let  CHAT_NOTI = "chat_noti"
    static let  POOL_NOTI = "pool_noti"
}

public struct FirebaseEvent {
   static let  CREATE_POOL_CLICKED = "create_pool_clicked"
   static let  POOL_CREATED = "pool_created"
    
   static let  SIGN_UP = "sign_up"
   static let  SIGN_UP_COMPLETE = "sign_up_complete"
   static let  SIGN_UP_CLICKED = "sign_up_clicked"
    
   static let  LOGIN = "login"
   static let  LOGIN_CLICKED = "login_clicked"
   static let  GET_STARTED = "get_started"
    
   static let  UPDATE_PROFILE = "update_profile"
    
   static let  EDIT_PROFILE_CLICKED = "edit_profile_clicked"
    
   static let  SETTINGS_CLICKED = "settings_clicked"
    
   static let  CONTACT_US_CLICKED = "contact_us_clicked"
    
   static let  ABOUT_US_CLICKED = "about_us_clicked"
    
   static let  TERMS_CLICKED = "terms_clicked"
    
   static let  PRIVACY_CLICKED = "privacy_clicked"
    
   static let  CHAT_CLICKED = "chat_clicked"
    
   static let  SINGLE_CHAT = "single_chat"
    
   static let  REFRESH_EVT_CLICKED = "refresh_evt_clicked"
    
   static let  LEAVE_POOL_CLICKED = "leave_pool_clicked"
    
   static let  RETURN_POOL_CLICKED = "return_pool_clicked"
    
   static let  KEEP_SYWMING = "keep_swyming"
    
   static let  SINGLE_POOL_CLICKED = "single_pool_clicked"
    
   static let  JOIN_POOL_CLICKED = "join_pool_clicked"
    
   static let  POOL_JOINED = "pool_joined"
    
   static let  POOL_LEFT = "pool_left"
    
   static let  POOL_USER_ACTION = "pool_user_action"
    
   static let  BREAK_THE_ICE_SUBMIT = "ice_submit"
    
   static let  REPORT_USER = "report_user"
    
   static let  END_CHAT = "end_chat"
    
   static let  LIKE_FB = "like_fb"
    
   static let  LOGOUT = "logout"
    
   static let  DELETE_ACCOUNT = "delete_acc"
    
   static let  CONTACT_US = "contact_us"
}
