defmodule CoreWeb.Templates.EmailTemplates.ForgetPassword do
  @moduledoc false
  def template("en", %{full_name: full_name, token: token, date_time: date_time, year: year}) do
    %{
      subject: "TUDO - Forget Password",
      html_body: """
        <!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional //EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

        <html xmlns="http://www.w3.org/1999/xhtml" xmlns:o="urn:schemas-microsoft-com:office:office" xmlns:v="urn:schemas-microsoft-com:vml">
        <head>
        <!--[if gte mso 9]><xml><o:OfficeDocumentSettings><o:AllowPNG/><o:PixelsPerInch>96</o:PixelsPerInch></o:OfficeDocumentSettings></xml><![endif]-->
        <meta content="text/html; charset=utf-8" http-equiv="Content-Type"/>
        <meta content="width=device-width" name="viewport"/>
        <!--[if !mso]><!-->
        <meta content="IE=edge" http-equiv="X-UA-Compatible"/>
        <!--<![endif]-->
        <title></title>
        <!--[if !mso]><!-->
        <!--<![endif]-->
        <style type="text/css">
        body {
        margin: 0;
        padding: 0;
        }

        table,
        td,
        tr {
        vertical-align: top;
        border-collapse: collapse;
        }

        * {
        line-height: inherit;
        }

        a[x-apple-data-detectors=true] {
        color: inherit !important;
        text-decoration: none !important;
        }
        </style>
        <style id="media-query" type="text/css">
        @media (max-width: 520px) {

        .block-grid,
        .col {
        min-width: 320px !important;
        max-width: 100% !important;
        display: block !important;
        }

        .block-grid {
        width: 100% !important;
        }

        .col {
        width: 100% !important;
        }

        .col>div {
        margin: 0 auto;
        }

        img.fullwidth,
        img.fullwidthOnMobile {
        max-width: 100% !important;
        }

        .no-stack .col {
        min-width: 0 !important;
        display: table-cell !important;
        }

        .no-stack.two-up .col {
        width: 50% !important;
        }

        .no-stack .col.num4 {
        width: 33% !important;
        }

        .no-stack .col.num8 {
        width: 66% !important;
        }

        .no-stack .col.num4 {
        width: 33% !important;
        }

        .no-stack .col.num3 {
        width: 25% !important;
        }

        .no-stack .col.num6 {
        width: 50% !important;
        }

        .no-stack .col.num9 {
        width: 75% !important;
        }

        .video-block {
        max-width: none !important;
        }

        .mobile_hide {
        min-height: 0px;
        max-height: 0px;
        max-width: 0px;
        display: none;
        overflow: hidden;
        font-size: 0px;
        }

        .desktop_hide {
        display: block !important;
        max-height: none !important;
        }
        }
        </style>
        </head>
        <body class="clean-body" style="margin: 0; padding: 0; -webkit-text-size-adjust: 100%; background-color: #FFFFFF;">
        <!--[if IE]><div class="ie-browser"><![endif]-->
        <table bgcolor="#FFFFFF" cellpadding="0" cellspacing="0" class="nl-container" role="presentation" style="table-layout: fixed; vertical-align: top; min-width: 320px; Margin: 0 auto; border-spacing: 0; border-collapse: collapse; mso-table-lspace: 0pt; mso-table-rspace: 0pt; background-color: #FFFFFF; width: 100%;" valign="top" width="100%">
        <tbody>
        <tr style="vertical-align: top;" valign="top">
        <td style="word-break: break-word; vertical-align: top;" valign="top">
        <!--[if (mso)|(IE)]><table width="100%" cellpadding="0" cellspacing="0" border="0"><tr><td align="center" style="background-color:#FFFFFF"><![endif]-->
        <div style="background-color:transparent;">
        <div class="block-grid" style="Margin: 0 auto; min-width: 320px; max-width: 500px; overflow-wrap: break-word; word-wrap: break-word; word-break: break-word; background-color: transparent;">
        <div style="border-collapse: collapse;display: table;width: 100%;background-color:transparent;">
        <!--[if (mso)|(IE)]><table width="100%" cellpadding="0" cellspacing="0" border="0" style="background-color:transparent;"><tr><td align="center"><table cellpadding="0" cellspacing="0" border="0" style="width:500px"><tr class="layout-full-width" style="background-color:transparent"><![endif]-->
        <!--[if (mso)|(IE)]><td align="center" width="500" style="background-color:transparent;width:500px; border-top: 0px solid transparent; border-left: 0px solid transparent; border-bottom: 0px solid transparent; border-right: 0px solid transparent;" valign="top"><table width="100%" cellpadding="0" cellspacing="0" border="0"><tr><td style="padding-right: 0px; padding-left: 0px; padding-top:5px; padding-bottom:5px;"><![endif]-->
        <div class="col num12" style="min-width: 320px; max-width: 500px; display: table-cell; vertical-align: top; width: 500px;">
        <div style="width:100% !important;">
        <!--[if (!mso)&(!IE)]><!-->
        <div style="border-top:0px solid transparent; border-left:0px solid transparent; border-bottom:0px solid transparent; border-right:0px solid transparent; padding-top:5px; padding-bottom:5px; padding-right: 0px; padding-left: 0px;">
        <!--<![endif]-->
        <div align="center" class="img-container center fixedwidth fullwidthOnMobile" style="padding-right: 0px;padding-left: 0px;">
        <!--[if mso]><table width="100%" cellpadding="0" cellspacing="0" border="0"><tr style="line-height:0px"><td style="padding-right: 0px;padding-left: 0px;" align="center"><![endif]--><a href="http://tudo.app" style="outline:none" tabindex="-1" target="_blank"> <img align="center" alt="TUDO.app" border="0" class="center fixedwidth fullwidthOnMobile" src="https://tudoicons.s3.amazonaws.com/Icons/TUDO.jpg" style="text-decoration: none; -ms-interpolation-mode: bicubic; height: auto; border: 0; width: 100%; max-width: 125px; display: block;" title="TUDO.app" width="125"/></a>
        <!--[if mso]></td></tr></table><![endif]-->
        </div>
        <table border="0" cellpadding="0" cellspacing="0" class="divider" role="presentation" style="table-layout: fixed; vertical-align: top; border-spacing: 0; border-collapse: collapse; mso-table-lspace: 0pt; mso-table-rspace: 0pt; min-width: 100%; -ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%;" valign="top" width="100%">
        <tbody>
        <tr style="vertical-align: top;" valign="top">
        <td class="divider_inner" style="word-break: break-word; vertical-align: top; min-width: 100%; -ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; padding-top: 10px; padding-right: 10px; padding-bottom: 10px; padding-left: 10px;" valign="top">
        <table align="center" border="0" cellpadding="0" cellspacing="0" class="divider_content" role="presentation" style="table-layout: fixed; vertical-align: top; border-spacing: 0; border-collapse: collapse; mso-table-lspace: 0pt; mso-table-rspace: 0pt; border-top: 1px solid #BBBBBB; width: 100%;" valign="top" width="100%">
        <tbody>
        <tr style="vertical-align: top;" valign="top">
        <td style="word-break: break-word; vertical-align: top; -ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%;" valign="top"><span></span></td>
        </tr>
        </tbody>
        </table>
        </td>
        </tr>
        </tbody>
        </table>
        <!--[if mso]><table width="100%" cellpadding="0" cellspacing="0" border="0"><tr><td style="padding-right: 10px; padding-left: 10px; padding-top: 10px; padding-bottom: 10px; font-family: Arial, sans-serif"><![endif]-->
        <div style="color:#555555;font-family:Arial, Helvetica Neue, Helvetica, sans-serif;line-height:1.2;padding-top:10px;padding-right:10px;padding-bottom:10px;padding-left:10px;">
        <div style="line-height: 1.2; font-size: 12px; color: #555555; font-family: Arial, Helvetica Neue, Helvetica, sans-serif; mso-line-height-alt: 14px;">
        <p style="line-height: 1.2; word-break: break-word; mso-line-height-alt: NaNpx; margin: 0;">Dear #{full_name},</p>
        <p style="line-height: 1.2; word-break: break-word; mso-line-height-alt: NaNpx; margin: 0;"> </p>
        </div>
        </div>
        <!--[if mso]></td></tr></table><![endif]-->
        <!--[if mso]><table width="100%" cellpadding="0" cellspacing="0" border="0"><tr><td style="padding-right: 10px; padding-left: 10px; padding-top: 10px; padding-bottom: 10px; font-family: Arial, sans-serif"><![endif]-->
        <div style="color:#555555;font-family:Arial, Helvetica Neue, Helvetica, sans-serif;line-height:1.2;padding-top:10px;padding-right:10px;padding-bottom:10px;padding-left:10px;">
        <div style="line-height: 1.2; font-size: 12px; color: #555555; font-family: Arial, Helvetica Neue, Helvetica, sans-serif; mso-line-height-alt: 14px;">
        <p style="line-height: 1.2; word-break: break-word; mso-line-height-alt: NaNpx; margin: 0;">You requested a reset password for your TUDO account, here is One-time password (OTP) to complete your request.</p>
        <p style="line-height: 1.2; word-break: break-word; mso-line-height-alt: NaNpx; margin: 0;"> </p>
        <p style="line-height: 1.2; word-break: break-word; mso-line-height-alt: NaNpx; margin: 0;"> </p>
        <p style="line-height: 1.2; word-break: break-word; mso-line-height-alt: NaNpx; margin: 0;">One-time password (OTP): #{token}</p>
        <p style="line-height: 1.2; word-break: break-word; font-size: 10px; mso-line-height-alt: 12px; margin: 0;"><span style="font-size: 10px; color: #ff0000;">* This OTP expires after 5 minutes from now #{date_time}</span></p>
        </div>
        </div>
        <!--[if mso]></td></tr></table><![endif]-->
        <!--[if mso]><table width="100%" cellpadding="0" cellspacing="0" border="0"><tr><td style="padding-right: 10px; padding-left: 10px; padding-top: 10px; padding-bottom: 10px; font-family: Arial, sans-serif"><![endif]-->
        <div style="color:#555555;font-family:Arial, Helvetica Neue, Helvetica, sans-serif;line-height:1.2;padding-top:10px;padding-right:10px;padding-bottom:10px;padding-left:10px;">
        <div style="line-height: 1.2; font-size: 12px; color: #555555; font-family: Arial, Helvetica Neue, Helvetica, sans-serif; mso-line-height-alt: 14px;">
        <p style="line-height: 1.2; word-break: break-word; mso-line-height-alt: NaNpx; margin: 0;"> </p>
        <p style="line-height: 1.2; word-break: break-word; mso-line-height-alt: NaNpx; margin: 0;">Thanks,</p>
        <p style="line-height: 1.2; word-break: break-word; mso-line-height-alt: NaNpx; margin: 0;">TUDO Team.</p>
        <p style="line-height: 1.2; word-break: break-word; mso-line-height-alt: NaNpx; margin: 0;"> </p>
        <p style="line-height: 1.2; word-break: break-word; mso-line-height-alt: NaNpx; margin: 0;">Click for the <a href="http://tudo.app/terms" rel="noopener" style="text-decoration: underline; color: #0068A5;" target="_blank" title="TUDO Terms and Conditions">Terms and Conditions</a> and the <a href="http://tudo.app/privacy" rel="noopener" style="text-decoration: underline; color: #0068A5;" target="_blank" title="TUDO Privacy Policy">Privacy Policy</a>.</p>
        </div>
        </div>
        <!--[if mso]></td></tr></table><![endif]-->
        <table border="0" cellpadding="0" cellspacing="0" class="divider" role="presentation" style="table-layout: fixed; vertical-align: top; border-spacing: 0; border-collapse: collapse; mso-table-lspace: 0pt; mso-table-rspace: 0pt; min-width: 100%; -ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%;" valign="top" width="100%">
        <tbody>
        <tr style="vertical-align: top;" valign="top">
        <td class="divider_inner" style="word-break: break-word; vertical-align: top; min-width: 100%; -ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; padding-top: 10px; padding-right: 10px; padding-bottom: 10px; padding-left: 10px;" valign="top">
        <table align="center" border="0" cellpadding="0" cellspacing="0" class="divider_content" role="presentation" style="table-layout: fixed; vertical-align: top; border-spacing: 0; border-collapse: collapse; mso-table-lspace: 0pt; mso-table-rspace: 0pt; border-top: 1px solid #BBBBBB; width: 100%;" valign="top" width="100%">
        <tbody>
        <tr style="vertical-align: top;" valign="top">
        <td style="word-break: break-word; vertical-align: top; -ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%;" valign="top"><span></span></td>
        </tr>
        </tbody>
        </table>
        </td>
        </tr>
        </tbody>
        </table>
        <!--[if mso]><table width="100%" cellpadding="0" cellspacing="0" border="0"><tr><td style="padding-right: 10px; padding-left: 10px; padding-top: 10px; padding-bottom: 10px; font-family: Arial, sans-serif"><![endif]-->
        <div style="color:#555555;font-family:Arial, Helvetica Neue, Helvetica, sans-serif;line-height:1.2;padding-top:10px;padding-right:10px;padding-bottom:10px;padding-left:10px;">
        <div style="line-height: 1.2; font-size: 12px; color: #555555; font-family: Arial, Helvetica Neue, Helvetica, sans-serif; mso-line-height-alt: 14px;">
        <p style="line-height: 1.2; word-break: break-word; font-size: 10px; mso-line-height-alt: 12px; margin: 0;"><span style="font-size: 10px;">Don't reply to this email. It was automatically generated.</span></p>
        <p style="line-height: 1.2; word-break: break-word; mso-line-height-alt: NaNpx; margin: 0;"> </p>
        <p style="line-height: 1.2; word-break: break-word; font-size: 10px; mso-line-height-alt: 12px; margin: 0;"><span style="font-size: 10px;">Check before you click!</span></p>
        <p style="line-height: 1.2; word-break: break-word; mso-line-height-alt: NaNpx; margin: 0;"> </p>
        <p style="line-height: 1.2; word-break: break-word; font-size: 10px; mso-line-height-alt: 12px; margin: 0;"><span style="font-size: 10px;">TUDO will never ask you for personal information in an email.</span></p>
        <p style="line-height: 1.2; word-break: break-word; font-size: 10px; mso-line-height-alt: 12px; margin: 0;"><span style="font-size: 10px;">When you click on a link, the address should always contain "tudo.app/".</span></p>
        <p style="line-height: 1.2; word-break: break-word; mso-line-height-alt: NaNpx; margin: 0;"> </p>
        <p style="line-height: 1.2; word-break: break-word; font-size: 10px; mso-line-height-alt: 12px; margin: 0;"><span style="font-size: 10px;"><a href="http://tudo.app/terms" rel="noopener" style="text-decoration: underline; color: #0068A5;" target="_blank" title="TUDO Terms and Conditions">Terms and Conditions</a>   <a href="http://tudo.app/privacy" rel="noopener" style="text-decoration: underline; color: #0068A5;" target="_blank" title="TUDO Privacy Policy">Privacy Policy</a>    <a href="http://tudo.app/legal" rel="noopener" style="text-decoration: underline; color: #0068A5;" target="_blank" title="TUDO Legal">Legal</a>    <a href="http://tudo.app/security" rel="noopener" style="text-decoration: underline; color: #0068A5;" target="_blank" title="TUDO Data Security">Security</a></span></p>
        <p style="line-height: 1.2; word-break: break-word; mso-line-height-alt: NaNpx; margin: 0;"> </p>
        <p style="line-height: 1.2; word-break: break-word; font-size: 10px; mso-line-height-alt: 12px; margin: 0;"><span style="font-size: 10px;">© #{year} TUDO.app, Inc. All rights reserved.</span></p>
        <p style="line-height: 1.2; word-break: break-word; font-size: 10px; mso-line-height-alt: 12px; margin: 0;"><span style="font-size: 10px;">TUDO and TUDO Shakehand Wheel are registered trademarks of TUDO.app, Inc.</span></p>
        <p style="line-height: 1.2; word-break: break-word; font-size: 10px; mso-line-height-alt: 12px; margin: 0;"><span style="font-size: 10px;">Terms and conditions, features, support, pricing, and service options subject to change without notice.</span></p>
        </div>
        </div>
        <!--[if mso]></td></tr></table><![endif]-->
        <!--[if (!mso)&(!IE)]><!-->
        </div>
        <!--<![endif]-->
        </div>
        </div>
        <!--[if (mso)|(IE)]></td></tr></table><![endif]-->
        <!--[if (mso)|(IE)]></td></tr></table></td></tr></table><![endif]-->
        </div>
        </div>
        </div>
        <!--[if (mso)|(IE)]></td></tr></table><![endif]-->
        </td>
        </tr>
        </tbody>
        </table>
        <!--[if (IE)]></div><![endif]-->
        </body>
        </html>
      """
    }
  end

  def template(_, %{full_name: full_name, token: token, date_time: date_time, year: year}) do
    %{
      subject: "TUDO - Forget Password",
      html_body: """
        <!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional //EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

        <html xmlns="http://www.w3.org/1999/xhtml" xmlns:o="urn:schemas-microsoft-com:office:office" xmlns:v="urn:schemas-microsoft-com:vml">
        <head>
        <!--[if gte mso 9]><xml><o:OfficeDocumentSettings><o:AllowPNG/><o:PixelsPerInch>96</o:PixelsPerInch></o:OfficeDocumentSettings></xml><![endif]-->
        <meta content="text/html; charset=utf-8" http-equiv="Content-Type"/>
        <meta content="width=device-width" name="viewport"/>
        <!--[if !mso]><!-->
        <meta content="IE=edge" http-equiv="X-UA-Compatible"/>
        <!--<![endif]-->
        <title></title>
        <!--[if !mso]><!-->
        <!--<![endif]-->
        <style type="text/css">
        body {
        margin: 0;
        padding: 0;
        }

        table,
        td,
        tr {
        vertical-align: top;
        border-collapse: collapse;
        }

        * {
        line-height: inherit;
        }

        a[x-apple-data-detectors=true] {
        color: inherit !important;
        text-decoration: none !important;
        }
        </style>
        <style id="media-query" type="text/css">
        @media (max-width: 520px) {

        .block-grid,
        .col {
        min-width: 320px !important;
        max-width: 100% !important;
        display: block !important;
        }

        .block-grid {
        width: 100% !important;
        }

        .col {
        width: 100% !important;
        }

        .col>div {
        margin: 0 auto;
        }

        img.fullwidth,
        img.fullwidthOnMobile {
        max-width: 100% !important;
        }

        .no-stack .col {
        min-width: 0 !important;
        display: table-cell !important;
        }

        .no-stack.two-up .col {
        width: 50% !important;
        }

        .no-stack .col.num4 {
        width: 33% !important;
        }

        .no-stack .col.num8 {
        width: 66% !important;
        }

        .no-stack .col.num4 {
        width: 33% !important;
        }

        .no-stack .col.num3 {
        width: 25% !important;
        }

        .no-stack .col.num6 {
        width: 50% !important;
        }

        .no-stack .col.num9 {
        width: 75% !important;
        }

        .video-block {
        max-width: none !important;
        }

        .mobile_hide {
        min-height: 0px;
        max-height: 0px;
        max-width: 0px;
        display: none;
        overflow: hidden;
        font-size: 0px;
        }

        .desktop_hide {
        display: block !important;
        max-height: none !important;
        }
        }
        </style>
        </head>
        <body class="clean-body" style="margin: 0; padding: 0; -webkit-text-size-adjust: 100%; background-color: #FFFFFF;">
        <!--[if IE]><div class="ie-browser"><![endif]-->
        <table bgcolor="#FFFFFF" cellpadding="0" cellspacing="0" class="nl-container" role="presentation" style="table-layout: fixed; vertical-align: top; min-width: 320px; Margin: 0 auto; border-spacing: 0; border-collapse: collapse; mso-table-lspace: 0pt; mso-table-rspace: 0pt; background-color: #FFFFFF; width: 100%;" valign="top" width="100%">
        <tbody>
        <tr style="vertical-align: top;" valign="top">
        <td style="word-break: break-word; vertical-align: top;" valign="top">
        <!--[if (mso)|(IE)]><table width="100%" cellpadding="0" cellspacing="0" border="0"><tr><td align="center" style="background-color:#FFFFFF"><![endif]-->
        <div style="background-color:transparent;">
        <div class="block-grid" style="Margin: 0 auto; min-width: 320px; max-width: 500px; overflow-wrap: break-word; word-wrap: break-word; word-break: break-word; background-color: transparent;">
        <div style="border-collapse: collapse;display: table;width: 100%;background-color:transparent;">
        <!--[if (mso)|(IE)]><table width="100%" cellpadding="0" cellspacing="0" border="0" style="background-color:transparent;"><tr><td align="center"><table cellpadding="0" cellspacing="0" border="0" style="width:500px"><tr class="layout-full-width" style="background-color:transparent"><![endif]-->
        <!--[if (mso)|(IE)]><td align="center" width="500" style="background-color:transparent;width:500px; border-top: 0px solid transparent; border-left: 0px solid transparent; border-bottom: 0px solid transparent; border-right: 0px solid transparent;" valign="top"><table width="100%" cellpadding="0" cellspacing="0" border="0"><tr><td style="padding-right: 0px; padding-left: 0px; padding-top:5px; padding-bottom:5px;"><![endif]-->
        <div class="col num12" style="min-width: 320px; max-width: 500px; display: table-cell; vertical-align: top; width: 500px;">
        <div style="width:100% !important;">
        <!--[if (!mso)&(!IE)]><!-->
        <div style="border-top:0px solid transparent; border-left:0px solid transparent; border-bottom:0px solid transparent; border-right:0px solid transparent; padding-top:5px; padding-bottom:5px; padding-right: 0px; padding-left: 0px;">
        <!--<![endif]-->
        <div align="center" class="img-container center fixedwidth fullwidthOnMobile" style="padding-right: 0px;padding-left: 0px;">
        <!--[if mso]><table width="100%" cellpadding="0" cellspacing="0" border="0"><tr style="line-height:0px"><td style="padding-right: 0px;padding-left: 0px;" align="center"><![endif]--><a href="http://tudo.app" style="outline:none" tabindex="-1" target="_blank"> <img align="center" alt="TUDO.app" border="0" class="center fixedwidth fullwidthOnMobile" src="https://tudoicons.s3.amazonaws.com/Icons/TUDO.jpg" style="text-decoration: none; -ms-interpolation-mode: bicubic; height: auto; border: 0; width: 100%; max-width: 125px; display: block;" title="TUDO.app" width="125"/></a>
        <!--[if mso]></td></tr></table><![endif]-->
        </div>
        <table border="0" cellpadding="0" cellspacing="0" class="divider" role="presentation" style="table-layout: fixed; vertical-align: top; border-spacing: 0; border-collapse: collapse; mso-table-lspace: 0pt; mso-table-rspace: 0pt; min-width: 100%; -ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%;" valign="top" width="100%">
        <tbody>
        <tr style="vertical-align: top;" valign="top">
        <td class="divider_inner" style="word-break: break-word; vertical-align: top; min-width: 100%; -ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; padding-top: 10px; padding-right: 10px; padding-bottom: 10px; padding-left: 10px;" valign="top">
        <table align="center" border="0" cellpadding="0" cellspacing="0" class="divider_content" role="presentation" style="table-layout: fixed; vertical-align: top; border-spacing: 0; border-collapse: collapse; mso-table-lspace: 0pt; mso-table-rspace: 0pt; border-top: 1px solid #BBBBBB; width: 100%;" valign="top" width="100%">
        <tbody>
        <tr style="vertical-align: top;" valign="top">
        <td style="word-break: break-word; vertical-align: top; -ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%;" valign="top"><span></span></td>
        </tr>
        </tbody>
        </table>
        </td>
        </tr>
        </tbody>
        </table>
        <!--[if mso]><table width="100%" cellpadding="0" cellspacing="0" border="0"><tr><td style="padding-right: 10px; padding-left: 10px; padding-top: 10px; padding-bottom: 10px; font-family: Arial, sans-serif"><![endif]-->
        <div style="color:#555555;font-family:Arial, Helvetica Neue, Helvetica, sans-serif;line-height:1.2;padding-top:10px;padding-right:10px;padding-bottom:10px;padding-left:10px;">
        <div style="line-height: 1.2; font-size: 12px; color: #555555; font-family: Arial, Helvetica Neue, Helvetica, sans-serif; mso-line-height-alt: 14px;">
        <p style="line-height: 1.2; word-break: break-word; mso-line-height-alt: NaNpx; margin: 0;">Dear #{full_name},</p>
        <p style="line-height: 1.2; word-break: break-word; mso-line-height-alt: NaNpx; margin: 0;"> </p>
        </div>
        </div>
        <!--[if mso]></td></tr></table><![endif]-->
        <!--[if mso]><table width="100%" cellpadding="0" cellspacing="0" border="0"><tr><td style="padding-right: 10px; padding-left: 10px; padding-top: 10px; padding-bottom: 10px; font-family: Arial, sans-serif"><![endif]-->
        <div style="color:#555555;font-family:Arial, Helvetica Neue, Helvetica, sans-serif;line-height:1.2;padding-top:10px;padding-right:10px;padding-bottom:10px;padding-left:10px;">
        <div style="line-height: 1.2; font-size: 12px; color: #555555; font-family: Arial, Helvetica Neue, Helvetica, sans-serif; mso-line-height-alt: 14px;">
        <p style="line-height: 1.2; word-break: break-word; mso-line-height-alt: NaNpx; margin: 0;">You requested a reset password for your TUDO account, here is One-time password (OTP) to complete your request.</p>
        <p style="line-height: 1.2; word-break: break-word; mso-line-height-alt: NaNpx; margin: 0;"> </p>
        <p style="line-height: 1.2; word-break: break-word; mso-line-height-alt: NaNpx; margin: 0;"> </p>
        <p style="line-height: 1.2; word-break: break-word; mso-line-height-alt: NaNpx; margin: 0;">One-time password (OTP): #{token}</p>
        <p style="line-height: 1.2; word-break: break-word; font-size: 10px; mso-line-height-alt: 12px; margin: 0;"><span style="font-size: 10px; color: #ff0000;">* This OTP expires after 5 minutes from now #{date_time}</span></p>
        </div>
        </div>
        <!--[if mso]></td></tr></table><![endif]-->
        <!--[if mso]><table width="100%" cellpadding="0" cellspacing="0" border="0"><tr><td style="padding-right: 10px; padding-left: 10px; padding-top: 10px; padding-bottom: 10px; font-family: Arial, sans-serif"><![endif]-->
        <div style="color:#555555;font-family:Arial, Helvetica Neue, Helvetica, sans-serif;line-height:1.2;padding-top:10px;padding-right:10px;padding-bottom:10px;padding-left:10px;">
        <div style="line-height: 1.2; font-size: 12px; color: #555555; font-family: Arial, Helvetica Neue, Helvetica, sans-serif; mso-line-height-alt: 14px;">
        <p style="line-height: 1.2; word-break: break-word; mso-line-height-alt: NaNpx; margin: 0;"> </p>
        <p style="line-height: 1.2; word-break: break-word; mso-line-height-alt: NaNpx; margin: 0;">Thanks,</p>
        <p style="line-height: 1.2; word-break: break-word; mso-line-height-alt: NaNpx; margin: 0;">TUDO Team.</p>
        <p style="line-height: 1.2; word-break: break-word; mso-line-height-alt: NaNpx; margin: 0;"> </p>
        <p style="line-height: 1.2; word-break: break-word; mso-line-height-alt: NaNpx; margin: 0;">Click for the <a href="http://tudo.app/terms" rel="noopener" style="text-decoration: underline; color: #0068A5;" target="_blank" title="TUDO Terms and Conditions">Terms and Conditions</a> and the <a href="http://tudo.app/privacy" rel="noopener" style="text-decoration: underline; color: #0068A5;" target="_blank" title="TUDO Privacy Policy">Privacy Policy</a>.</p>
        </div>
        </div>
        <!--[if mso]></td></tr></table><![endif]-->
        <table border="0" cellpadding="0" cellspacing="0" class="divider" role="presentation" style="table-layout: fixed; vertical-align: top; border-spacing: 0; border-collapse: collapse; mso-table-lspace: 0pt; mso-table-rspace: 0pt; min-width: 100%; -ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%;" valign="top" width="100%">
        <tbody>
        <tr style="vertical-align: top;" valign="top">
        <td class="divider_inner" style="word-break: break-word; vertical-align: top; min-width: 100%; -ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; padding-top: 10px; padding-right: 10px; padding-bottom: 10px; padding-left: 10px;" valign="top">
        <table align="center" border="0" cellpadding="0" cellspacing="0" class="divider_content" role="presentation" style="table-layout: fixed; vertical-align: top; border-spacing: 0; border-collapse: collapse; mso-table-lspace: 0pt; mso-table-rspace: 0pt; border-top: 1px solid #BBBBBB; width: 100%;" valign="top" width="100%">
        <tbody>
        <tr style="vertical-align: top;" valign="top">
        <td style="word-break: break-word; vertical-align: top; -ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%;" valign="top"><span></span></td>
        </tr>
        </tbody>
        </table>
        </td>
        </tr>
        </tbody>
        </table>
        <!--[if mso]><table width="100%" cellpadding="0" cellspacing="0" border="0"><tr><td style="padding-right: 10px; padding-left: 10px; padding-top: 10px; padding-bottom: 10px; font-family: Arial, sans-serif"><![endif]-->
        <div style="color:#555555;font-family:Arial, Helvetica Neue, Helvetica, sans-serif;line-height:1.2;padding-top:10px;padding-right:10px;padding-bottom:10px;padding-left:10px;">
        <div style="line-height: 1.2; font-size: 12px; color: #555555; font-family: Arial, Helvetica Neue, Helvetica, sans-serif; mso-line-height-alt: 14px;">
        <p style="line-height: 1.2; word-break: break-word; font-size: 10px; mso-line-height-alt: 12px; margin: 0;"><span style="font-size: 10px;">Don't reply to this email. It was automatically generated.</span></p>
        <p style="line-height: 1.2; word-break: break-word; mso-line-height-alt: NaNpx; margin: 0;"> </p>
        <p style="line-height: 1.2; word-break: break-word; font-size: 10px; mso-line-height-alt: 12px; margin: 0;"><span style="font-size: 10px;">Check before you click!</span></p>
        <p style="line-height: 1.2; word-break: break-word; mso-line-height-alt: NaNpx; margin: 0;"> </p>
        <p style="line-height: 1.2; word-break: break-word; font-size: 10px; mso-line-height-alt: 12px; margin: 0;"><span style="font-size: 10px;">TUDO will never ask you for personal information in an email.</span></p>
        <p style="line-height: 1.2; word-break: break-word; font-size: 10px; mso-line-height-alt: 12px; margin: 0;"><span style="font-size: 10px;">When you click on a link, the address should always contain "tudo.app/".</span></p>
        <p style="line-height: 1.2; word-break: break-word; mso-line-height-alt: NaNpx; margin: 0;"> </p>
        <p style="line-height: 1.2; word-break: break-word; font-size: 10px; mso-line-height-alt: 12px; margin: 0;"><span style="font-size: 10px;"><a href="http://tudo.app/terms" rel="noopener" style="text-decoration: underline; color: #0068A5;" target="_blank" title="TUDO Terms and Conditions">Terms and Conditions</a>   <a href="http://tudo.app/privacy" rel="noopener" style="text-decoration: underline; color: #0068A5;" target="_blank" title="TUDO Privacy Policy">Privacy Policy</a>    <a href="http://tudo.app/legal" rel="noopener" style="text-decoration: underline; color: #0068A5;" target="_blank" title="TUDO Legal">Legal</a>    <a href="http://tudo.app/security" rel="noopener" style="text-decoration: underline; color: #0068A5;" target="_blank" title="TUDO Data Security">Security</a></span></p>
        <p style="line-height: 1.2; word-break: break-word; mso-line-height-alt: NaNpx; margin: 0;"> </p>
        <p style="line-height: 1.2; word-break: break-word; font-size: 10px; mso-line-height-alt: 12px; margin: 0;"><span style="font-size: 10px;">© #{year} TUDO.app, Inc. All rights reserved.</span></p>
        <p style="line-height: 1.2; word-break: break-word; font-size: 10px; mso-line-height-alt: 12px; margin: 0;"><span style="font-size: 10px;">TUDO and TUDO Shakehand Wheel are registered trademarks of TUDO.app, Inc.</span></p>
        <p style="line-height: 1.2; word-break: break-word; font-size: 10px; mso-line-height-alt: 12px; margin: 0;"><span style="font-size: 10px;">Terms and conditions, features, support, pricing, and service options subject to change without notice.</span></p>
        </div>
        </div>
        <!--[if mso]></td></tr></table><![endif]-->
        <!--[if (!mso)&(!IE)]><!-->
        </div>
        <!--<![endif]-->
        </div>
        </div>
        <!--[if (mso)|(IE)]></td></tr></table><![endif]-->
        <!--[if (mso)|(IE)]></td></tr></table></td></tr></table><![endif]-->
        </div>
        </div>
        </div>
        <!--[if (mso)|(IE)]></td></tr></table><![endif]-->
        </td>
        </tr>
        </tbody>
        </table>
        <!--[if (IE)]></div><![endif]-->
        </body>
        </html>
      """
    }
  end
end
