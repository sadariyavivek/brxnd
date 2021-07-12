//
//  Current.swift
//  brXnd
//
//  Created by Andrian Sergheev on 2019-03-26.
//  Copyright © 2019 Andrian Sergheev. All rights reserved.
//

// swiftlint:disable all
var Current = Environment()

public enum SocialMediaState {
	case loggedInWeb
	case loggedInFacebook
}

extension SocialMediaState {}


struct Environment {

	private (set)var date: () -> Date = Date.init

	#if DEBUG
	private (set)var networkEnvironment: NetworkEnvironment = .staging
	#else
	private (set)var networkEnvironment: NetworkEnvironment = .prod
	#endif

//	private (set)var networkEnvironment: NetworkEnvironment = .prod
	
	func getHeadersWithAccessToken() -> [String:String] {
		switch self.networkEnvironment {
		case .prod:
			return ["Accept": "application/json",
					"Authorization": "Bearer " + user!.webAccessToken!]
		default:
			return ["Accept": "application/json",
					"Authorization": stagingAuthToken]
		}
	}

	public func getLoggedInState() -> SocialMediaState {
		if Current.user?.facebookData?.tokenString == nil {
			return .loggedInWeb
		} else {
			return .loggedInFacebook
		}
	}


	//	 Vasile acc acc
   
   /* eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiIsImp0aSI6IjhmN2MxNGFjZmNlN2EwYjY4MmZhYzI5Mzc0YjMxNzhlN2VhZWE1ZmIyYzQ2MTAxYmQ0NjJmN2VjNjE2YTQwYjYyNGQ4YmE1MGQ5OGUzNzAwIn0.eyJhdWQiOiIyIiwianRpIjoiOGY3YzE0YWNmY2U3YTBiNjgyZmFjMjkzNzRiMzE3OGU3ZWFlYTVmYjJjNDYxMDFiZDQ2MmY3ZWM2MTZhNDBiNjI0ZDhiYTUwZDk4ZTM3MDAiLCJpYXQiOjE1ODAxOTczOTksIm5iZiI6MTU4MDE5NzM5OSwiZXhwIjoxNjExODE5Nzk5LCJzdWIiOiIyMyIsInNjb3BlcyI6W119.glFRPvcBhMo9TtH0AbSTPMpsw5-4k5GR4Ad0sxqvXORX6cEEQkrABtOVF_X_Z6yIF68JRbxnArq6HoITc7y_cEjXpGpnUgt14rH5-nW8i2hjoyvnXkcV6e7dZzkYaI6I23iocfcN6jVoXOTvhbHVRNXaW-aVyCsiPWDM2f9sZisAyAoJ5KsWH3Jwo6B6-ZK07nPDzUCpPndgayNwVFroel_pnk2Zz4X46drrj4LYzPNlzsyCLMa2Ot96ZdR01MuAMTvK8FKYVvmm_cL3j2l0PCF5J0zWyuYzRypZQyJyVxuE7Gewfgnn4h_kBYP8NKaD5kmWLXFRqjxoHJQJ8K4helOWPLGPAKgcvU6XsRpbAS7h4a4TthVKhbPXvbZJKZonCyoIoXlC7Q9BI04CK7OZnBlfF42LOATcaLzmVEEmSAhL3RlQycyKVWWbL5gmQdYw6G6dviBQtw355ulFYk0RWsgfQvnpJFkyj8pYeWRFYjQP8EMl3njd7WKDjVSSll4uDw6j5GfubrnCou5nFoqtgVwVXV1NBeaTBWNUbgYrzTlm8wkDk8CqMfh7N1fj2BLBkom90H4cYDXE3vXKeYpa-AYCZurHHUN_z9GJjJaRWP2SBAhWOv5gkdfzUxmYK8hRlOTZ63mfb3E9Npl_60E1RawFZE9KJkIzYtEsBM4ltfs
    eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiIsImp0aSI6ImI4NzQ3MmFkYTI3MGRhYmM1NGM5M2UxM2RjNjg4MmFjNTgxOWEwMzMxMGJhOTA1ZTE3ZTI0ZGMzMmYyNzYyZGM1ZjBlN2RhOTA1Zjc0NzYyIn0.eyJhdWQiOiIyIiwianRpIjoiYjg3NDcyYWRhMjcwZGFiYzU0YzkzZTEzZGM2ODgyYWM1ODE5YTAzMzEwYmE5MDVlMTdlMjRkYzMyZjI3NjJkYzVmMGU3ZGE5MDVmNzQ3NjIiLCJpYXQiOjE1NzMxMzUzMTUsIm5iZiI6MTU3MzEzNTMxNSwiZXhwIjoxNjA0NzU3NzE1LCJzdWIiOiI2NSIsInNjb3BlcyI6W119.GH80UX1v3CqB52Dsc5AEMh3_Ft6hVCG37lwUbeIoHQu82q0qP0g_GNcrPNH2nztgVV68JT1D0ZfeWmZNOlLw1_RP8XkoUlMitTWIJ8t8MfcY3CjxmYvhn53eMACjjpB_K-EA0_QvycL_35mAzjO2lb8N-RjkCXOVIDQ6ikFfXJZeJmWe9IpD3ZpOH5oqffqjxZB2w0JOvQqQJbpQr8HncFNUDYm_Svt5v5Ddir37k-B2ZjD-2RKnwt1fFyHYnulF2MvMfExOiLCf-xUSPOxlxoi3hR7QRhRmlkGYZltyjqp30iERAZ41s9sgqRahWThiaTlMOmbEM9aAsqAbNLvYabRJfRhGI2dpdZ1oifnmpJb4OLGyq_DpXwF_aBn7DrTvVNWRwScfkG3PhZLZvjo5RRhui6IAnA7GlWjchRyeAV9una0fOpSXN8PBp7WKtJGo85ArMFO45oA7JgjTFoBacDedo5s-0iym2nMNinex7zocUU4NGufdk75YcVteqKTfQ74y2un8vdfIyoIhuENbv2DImyjussX0FwXWkgXTLS4avfttb1m0wMhrdDfKF1aSxZvvcCVbLV1eb0OtXLnOeJz0L3wP0Cys8SpLXFKWXnUTnMhKSYmMYNtmaGKJAkkeeKmQhkomRUj3Xuo2_R1nDDMqE9UM9go5_aXMJyUoHFM
     eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiIsImp0aSI6Ijg5YTc0MWY5YjEyMWVjYWE0MDA5NjlhODVkZGEzMzRjMmNiOWRiNGM0NjBmNGFlYjM3NjVmMmQ1MWIxYTQ4ZTJlZjhmNTA2OWM0OGY2OGYzIn0.eyJhdWQiOiIyIiwianRpIjoiODlhNzQxZjliMTIxZWNhYTQwMDk2OWE4NWRkYTMzNGMyY2I5ZGI0YzQ2MGY0YWViMzc2NWYyZDUxYjFhNDhlMmVmOGY1MDY5YzQ4ZjY4ZjMiLCJpYXQiOjE1ODA5ODM3MDksIm5iZiI6MTU4MDk4MzcwOSwiZXhwIjoxNjEyNjA2MTA5LCJzdWIiOiIyMzkiLCJzY29wZXMiOltdfQ.ubSc2NiqgM2A9tb4bdJq4Fwp_Kp83GKl97OYPoo4VEAi_xYqv5uwO2oXlPDDEFPHCmsrZuc-ELFY46pLyCyFTfNi7uSGxGoC5TyzIH5w3nm7izTK5gOdJtEpic2cs4hzKlTA0exXlBG_UAcWXbjEa5RjTKqi1FjqQIlIdvVtUFxjiUBBHjgMP_07OWKrnUeDcmtcV8PsNiSF-tbU_JTs4QK1WoWqX4pMpdZd6mbB5WkXF8Wu6Z-OVL60iK4ew8pRLIkz2xHuu3Anfa1fKMmX3JP-HXVt0D2CglEg5loRyHBnZlmWPzcBNlG4W9vgDPqq9CxNCGeg_LS8DbKgVRbiICQAR7e9ZmH9mIzR_ycaJtl_8Qph8d9PgE_NVnA1YrBooZgeBpvXzURzFPDk8gPNgCXUsHvhX8I9R-jcFRUprIdXbe3XxDoBmPvhKj0PTRkDGfuOPnXRiqFppX2Y8Q1eiGKsct9QOgsjY3wiJPlxJMeeVwH_ITVJY-7jf2TCq2aHboC8iSCV0NuiCxGW-iSJv3Vb_iThBP0mIVau1H6f-d14LQSbIDZLaMD4ukTCN1zubBYJPFADuY2LW0GgjBNFJ0HfK1tEKuI9jO4Wul6h5Qamf2dDGJna7L0TF-9GhRxhIETeblhIYcmXc-f-mw9z4YJrclNR6le8hcJ-klRJlyU
     */
//	private (set)var stagingAuthToken: String = """
//Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiIsImp0aSI6IjhmN2MxNGFjZmNlN2EwYjY4MmZhYzI5Mzc0YjMxNzhlN2VhZWE1ZmIyYzQ2MTAxYmQ0NjJmN2VjNjE2YTQwYjYyNGQ4YmE1MGQ5OGUzNzAwIn0.eyJhdWQiOiIyIiwianRpIjoiOGY3YzE0YWNmY2U3YTBiNjgyZmFjMjkzNzRiMzE3OGU3ZWFlYTVmYjJjNDYxMDFiZDQ2MmY3ZWM2MTZhNDBiNjI0ZDhiYTUwZDk4ZTM3MDAiLCJpYXQiOjE1ODAxOTczOTksIm5iZiI6MTU4MDE5NzM5OSwiZXhwIjoxNjExODE5Nzk5LCJzdWIiOiIyMyIsInNjb3BlcyI6W119.glFRPvcBhMo9TtH0AbSTPMpsw5-4k5GR4Ad0sxqvXORX6cEEQkrABtOVF_X_Z6yIF68JRbxnArq6HoITc7y_cEjXpGpnUgt14rH5-nW8i2hjoyvnXkcV6e7dZzkYaI6I23iocfcN6jVoXOTvhbHVRNXaW-aVyCsiPWDM2f9sZisAyAoJ5KsWH3Jwo6B6-ZK07nPDzUCpPndgayNwVFroel_pnk2Zz4X46drrj4LYzPNlzsyCLMa2Ot96ZdR01MuAMTvK8FKYVvmm_cL3j2l0PCF5J0zWyuYzRypZQyJyVxuE7Gewfgnn4h_kBYP8NKaD5kmWLXFRqjxoHJQJ8K4helOWPLGPAKgcvU6XsRpbAS7h4a4TthVKhbPXvbZJKZonCyoIoXlC7Q9BI04CK7OZnBlfF42LOATcaLzmVEEmSAhL3RlQycyKVWWbL5gmQdYw6G6dviBQtw355ulFYk0RWsgfQvnpJFkyj8pYeWRFYjQP8EMl3njd7WKDjVSSll4uDw6j5GfubrnCou5nFoqtgVwVXV1NBeaTBWNUbgYrzTlm8wkDk8CqMfh7N1fj2BLBkom90H4cYDXE3vXKeYpa-AYCZurHHUN_z9GJjJaRWP2SBAhWOv5gkdfzUxmYK8hRlOTZ63mfb3E9Npl_60E1RawFZE9KJkIzYtEsBM4ltfs
    
    
    
//"""
    
        private (set)var stagingAuthToken: String = """
    Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiIsImp0aSI6IjNjMmU5ZGU0NDgyNDNlYTY0ZmZhOTFkNzRlOGJkNWJhZDhkZDRlMjY0OTgxZGM3MmIwMjQ4Yzc0YzJjN2UxOWRlNGNhZmU5ZDQ2Nzk1YmUxIn0.eyJhdWQiOiIyIiwianRpIjoiM2MyZTlkZTQ0ODI0M2VhNjRmZmE5MWQ3NGU4YmQ1YmFkOGRkNGUyNjQ5ODFkYzcyYjAyNDhjNzRjMmM3ZTE5ZGU0Y2FmZTlkNDY3OTViZTEiLCJpYXQiOjE1ODMzODY1NjUsIm5iZiI6MTU4MzM4NjU2NSwiZXhwIjoxNjE0OTIyNTY1LCJzdWIiOiI4NSIsInNjb3BlcyI6W119.OR73svvwcL4owJb0NkMTh1MlUsIMMD_KM5ByngqQ9yQEDxOlhnp07f9xfCiNcyK36DGRXR_G225j8GgWkyrGHdNqgg5_mAwWM7Lg_gutjlutcosVdUFxTpki8zy_hKEJFMqs2MMkumDlAtEMlStf37MeJYOZKasgFx8ILaWIwfjd0AMMeVCz7BcLjnZOcTZ-MVC0J-ctMCC50Bbrk8q6B3mM0dGH2H1WW61PGEyOoEE-m8W-sKzveYXO3DzG-neI_Z2peRnr0qA1m1xnTPN8JK6rwHN0NZx05xA60ZzxKEMvUPBtVe129PEKeWpfPRnzcR_biqzFJl8kWaHnffjdmtYwwbASyu_X4HnavYY8Vv7qCFpQachp-3OqDQr3qkTdTkJBVBuwI7qok-2MWZDH8gvlEuSxakkudIsRs-xdQU8D64GVJG0hwGCJ6eFUExxKZ9-CQzDg3sq6WNtbmktMjFKXZAi4SKCFLkFSWdrR75kVfljNlgQd577feBpgHWScWVfSV6wp3RKJJ9yHEOWbFFFtoJp8Zlnfrg6Cke3qqbJ_nE32blI6YKQBlmO5Rb-SGfJXiPwBMAPcbcaIkOxsnb069dJLRi5_C_vkUFcZGnTUpE8h36ZR9zIoIFoCjB1eYopPLwQbTdP0pzhtWwU8eiULE9Fwpo8uiTD9TFk6Ma4
    """

	var user: User? = AuthHelper.retrieveUser() {
		///save to keychain for all changes.
		didSet {
			AuthHelper.saveUser(user)
		}
	}

	/* Temporary */

	//Support
	private (set)var supportEmail: String = "hello@brxnding.com.au"
	private (set)var privacyPolicy: String = """
PRIVACY POLICY
Grande Parade Pty Ltd
We respect your privacy
Grande Parade Pty Ltd respects your right to privacy and is committed to safeguarding the privacy of our customers and website visitors. This policy sets out how we collect and treat your personal information.
We adhere to the Australian Privacy Principles contained in the Privacy Act 1988 (Cth) and to the extent applicable, the EU General Data Protection Regulation (GDPR).
"Personal information" is information we hold which is identifiable as being about you. This includes information such as your name, email address, identification number, or any other type of information that can reasonably identify an individual, either directly or indirectly.
You may contact us in writing at 325 Fullarton Road, Parkside, South Australia, 5063 for further information about this Privacy Policy.
What personal information is collected
Grande Parade Pty Ltd will, from time to time, receive and store personal information you submit to our website, provided to us directly or given to us in other forms.
You may provide basic information such as your name, phone number, address and email address to enable us to send you information, provide updates and process your product or service order.
We may collect additional information at other times, including but not limited to, when you provide feedback, when you provide information about your personal or business affairs, change your content or email preference, respond to surveys and/or promotions, provide financial or credit card information, or communicate with our customer support.
Additionally, we may also collect any other information you provide while interacting with us.
How we collect your personal information
Grande Parade Pty Ltd collects personal information from you in a variety of ways, including when you interact with us electronically or in person, when you access our website and when we engage in business activities with you. We may receive personal information from third parties. If we do, we will protect it as set out in this Privacy Policy.
By providing us with personal information, you consent to the supply of that information subject to the terms of this Privacy Policy.
How we use your personal information
Grande Parade Pty Ltd may use personal information collected from you to provide you with information about our products or services. We may also make you aware of new and additional products, services and opportunities available to you.
Grande Parade Pty Ltd will use personal information only for the purposes that you consent to. This may include to:
provide you with products and services during the usual course of our business activities;
administer our business activities;
manage, research and develop our products and services;
provide you with information about our products and services;
communicate with you by a variety of measures including, but not limited to, by telephone, email, sms or mail; and
investigate any complaints.
If you withhold your personal information, it may not be possible for us to provide you with our products and services or for you to fully access our website.
We may disclose your personal information to comply with a legal requirement, such as a law, regulation, court order, subpoena, warrant, legal proceedings or in response to a law enforcement agency request.
If there is a change of control in our business or a sale or transfer of business assets, we reserve the right to transfer to the extent permissible at law our user databases, together with any personal information and non-personal information contained in those databases.
Disclosure of your personal information
Grande Parade Pty Ltd may disclose your personal information to any of our employees, officers, insurers, professional advisers, agents, suppliers or subcontractors insofar as reasonably necessary for the purposes set out in this privacy policy.
If we do disclose your personal information to a third party, we will protect it in accordance with this privacy policy.
General Data Protection Regulation (GDPR) for the European Union (EU)
Grande Parade Pty Ltd will comply with the principles of data protection set out in the GDPR for the purpose of fairness, transparency and lawful data collection and use.
We process your personal information as a Processor and/or to the extent that we are a Controller as defined in the GDPR.
We must establish a lawful basis for processing your personal information. The legal basis for which we collect your personal information depends on the data that we collect and how we use it.
We will only collect your personal information with your express consent for a specific purpose and any data collected will be to the extent necessary and not excessive for its purpose. We will keep your data safe and secure.
We will also process your personal information if it is necessary for our legitimate interests, or to fulfil a contractual or legal obligation.
We process your personal information if it is necessary to protect your life or in a medical situation, it is necessary to carry out a public function, a task of public interest or if the function has a clear basis in law.
We do not collect or process any personal information from you that is considered "Sensitive Personal Information" under the GDPR, such as personal information relating to your sexual orientation or ethnic origin unless we have obtained your explicit consent, or if it is being collected subject to and in accordance with the GDPR.
You must not provide us with your personal information if you are under the age of 16 without the consent of your parent or someone who has parental authority for you. We do not knowingly collect or process the personal information of children.
Your rights under the GDPR
If you are an individual residing in the EU, you have certain rights as to how your personal information is obtained and used. Grande Parade Pty Ltd complies with your rights under the GDPR as to how your personal information is used and controlled if you are an individual residing in the EU
Except as otherwise provided in the GDPR, you have the following rights:
to be informed how your personal information is being used;
access your personal information (we will provide you with a free copy of it);
to correct your personal information if it is inaccurate or incomplete;
to delete your personal information (also known as "the right to be forgotten");
to restrict processing of your personal information;
to retain and reuse your personal information for your own purposes;
to object to your personal information being used; and
to object against automated decision making and profiling.
Please contact us at any time to exercise your rights under the GDPR at the contact details in this Privacy Policy.
We may ask you to verify your identity before acting on any of your requests.
Hosting and International Data Transfers
Information that we collect may from time to time be stored, processed in or transferred between parties or sites located in countries outside of Australia. These may include, but are not limited to Australia and USA.
We and our other group companies have offices and/or facilities in Australia and USA. Transfers to each of these countries will be protected by appropriate safeguards, these include one or more of the following: the use of standard data protection clauses adopted or approved by the European Commission which you can obtain from the European Commission Website; the use of binding corporate rules, a copy of which you can obtain from Grande Parade Pty Ltd's Data Protection Officer.
The hosting facilities for our website are situated in Australia and USA. Transfers to each of these Countries will be protected by appropriate safeguards, these include one or more of the following: the use of standard data protection clauses adopted or approved by the European Commission which you can obtain from the European Commission Website; the use of binding corporate rules, a copy of which you can obtain from Grande Parade Pty Ltd's Data Protection Officer.
Our Suppliers and Contractors are situated in Australia and USA. Transfers to each of these Countries will be protected by appropriate safeguards, these include one or more of the following: the use of standard data protection clauses adopted or approved by the European Commission which you can obtain from the European Commission Website; the use of binding corporate rules, a copy of which you can obtain from Grande Parade Pty Ltd's Data Protection Officer.
You acknowledge that personal data that you submit for publication through our website or services may be available, via the internet, around the world. We cannot prevent the use (or misuse) of such personal data by others.
Security of your personal information
Grande Parade Pty Ltd is committed to ensuring that the information you provide to us is secure. In order to prevent unauthorised access or disclosure, we have put in place suitable physical, electronic and managerial procedures to safeguard and secure information and protect it from misuse, interference, loss and unauthorised access, modification and disclosure.
Where we employ data processors to process personal information on our behalf, we only do so on the basis that such data processors comply with the requirements under the GDPR and that have adequate technical measures in place to protect personal information against unauthorised use, loss and theft.
The transmission and exchange of information is carried out at your own risk. We cannot guarantee the security of any information that you transmit to us, or receive from us.  Although we take measures to safeguard against unauthorised disclosures of information, we cannot assure you that personal information that we collect will not be disclosed in a manner that is inconsistent with this Privacy Policy.
Access to your personal information
You may request details of personal information that we hold about you in accordance with the provisions of the Privacy Act 1988 (Cth), and to the extent applicable the EU GDPR. If you would like a copy of the information which we hold about you or believe that any information we hold on you is inaccurate, out of date, incomplete, irrelevant or misleading, please email us at hello@brxnding.com.au.
We reserve the right to refuse to provide you with information that we hold about you, in certain circumstances set out in the Privacy Act or any other applicable law.
Complaints about privacy
If you have any complaints about our privacy practices, please feel free to send in details of your complaints to hello@brxnding.com.au. We take complaints very seriously and will respond shortly after receiving written notice of your complaint.
Changes to Privacy Policy
Please be aware that we may change this Privacy Policy in the future. We may modify this Policy at any time, in our sole discretion and all modifications will be effective immediately upon our posting of the modifications on our website or notice board. Please check back from time to time to review our Privacy Policy.
Website
When you visit our website
When you come to our website (https://www.brxnding.com.au/), we may collect certain information such as browser type, operating system, website visited immediately before coming to our site, etc. This information is used in an aggregated manner to analyse how people use our site, such that we can improve our service.
Cookies
We may from time to time use cookies on our website. Cookies are very small files which a website uses to identify you when you come back to the site and to store details about your use of the site. Cookies are not malicious programs that access or damage your computer. Most web browsers automatically accept cookies but you can choose to reject cookies by changing your browser settings. However, this may prevent you from taking full advantage of our website. Our website may from time to time use cookies to analyses website traffic and help us provide a better website visitor experience. In addition, cookies may be used to serve relevant ads to website visitors through third party services such as Google AdWords. These ads may appear on this website or other websites you visit.
Third party sites
Our site may from time to time have links to other websites not owned or controlled by us. These links are meant for your convenience only. Links to third party websites do not constitute sponsorship or endorsement or approval of these websites. Please be aware that Grande Parade Pty Ltd is not responsible for the privacy practises of other such websites. We encourage our users to be aware, when they leave our website, to read the privacy statements of each and every website that collects personal identifiable information.
13th June 2019
"""

	private (set)var termsConditions: String = """
Lorem ipsum dolor sit er elit lamet, consectetaur cillium adipisicing pecu, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum. Nam liber te conscient to factor tum poen legum odioque civiuda.
Lorem ipsum dolor sit er elit lamet, consectetaur cillium adipisicing pecu, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum. Nam liber te conscient to factor tum poen legum odioque civiuda.
Lorem ipsum dolor sit er elit lamet, consectetaur cillium adipisicing pecu, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum. Nam liber te conscient to factor tum poen legum odioque civiuda.
Lorem ipsum dolor sit er elit lamet, consectetaur cillium adipisicing pecu, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum. Nam liber te conscient to factor tum poen legum odioque civiuda.
"""
	/* Temporary */
}

extension Environment {

	static let mock = Environment(date: {Date(timeIntervalSinceReferenceDate: 557152051)},
								  networkEnvironment: .staging,
								  stagingAuthToken: "",
								  user: User(),
								  supportEmail: "hello@brxnding.com.au",
								  privacyPolicy: "",
								  termsConditions: "")

}
// swiftlint:enable all
