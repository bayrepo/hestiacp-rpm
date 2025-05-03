<div align="center">

# [हेस्टिया कंट्रोल पैनल (RPM संस्करण)](https://hestiadocs.brepo.ru)

![HestiaCP वेब इंटरफेस स्क्रीनशॉट](./docs/public/images/demo.png)

## आधुनिक वेब होस्टिंग वातावरण के लिए हल्का और शक्तिशाली सर्वर नियंत्रण पैनल

**स्थिर संस्करण:** 1.9.5 (RPM) |
[RPM संस्करण](https://hestiadocs.brepo.ru) |
[मूल Ubuntu/Debian प्रोजेक्ट](https://hestiacp.com) |
[परिवर्तन सूची](/CHANGELOG.md) |
[सहायता फोरम](https://forum.hestiacp.com)
<br><br>
[![Drone बिल्ड स्थिति](https://drone.hestiacp.com/api/badges/hestiacp/hestiacp/status.svg?ref=refs/heads/main)](https://drone.hestiacp.com/hestiacp/hestiacp)
[![कोड लिंट स्थिति](https://github.com/hestiacp/hestiacp/actions/workflows/lint.yml/badge.svg)](https://github.com/hestiacp/hestiacp/actions/workflows/lint.yml)
[![तकनीकी प्रश्नोत्तर](https://img.shields.io/badge/Gurubase-हेस्टिया_फोरम_में_अंग्रेजी_में_पूछें-006BFF)](https://gurubase.io/g/hestia)

</div>

हेस्टिया कंट्रोल पैनल (RPM संस्करण) RHEL-आधारित वितरणों पर केंद्रित एक स्वतंत्र टीम द्वारा विकसित और बनाए रखा जाता है। मूल प्रोजेक्ट से फोर्क होने के बाद, यह संस्करण अपस्ट्रीम Ubuntu/Debian संस्करण के साथ सीधे सिंक नहीं होता (कुछ सुविधाएँ RPM सिस्टम के लिए लागू नहीं हैं)। कृपया इस संस्करण से संबंधित समस्याओं को सीधे इस प्रोजेक्ट में रिपोर्ट करें।

निम्नलिखित पैनल का सामान्य विवरण है।

## **आपका स्वागत है!**

हेस्टिया कंट्रोल पैनल का उद्देश्य व्यवस्थापकों को वेबसाइट, ईमेल खाते, DNS ज़ोन और डेटाबेस को तेज़ी से तैनात करने और प्रबंधित करने के लिए एक केंद्रीकृत वेब इंटरफेस और कमांड-लाइन टूल्स प्रदान करना है - बिना अलग-अलग घटकों को मैन्युअल रूप से कॉन्फ़िगर किए।

## सुविधाएँ और सेवाएँ

- Apache2 और NGINX PHP-FPM के साथ
- बहु-PHP संस्करण समर्थन (7.4[EOL](https://www.php.net/supported-versions.php) - 8.3, डिफ़ॉल्ट 8.2 Remi रिपॉजिटरी से + कस्टम PHP बिल्ड)
- DNS सर्वर (Bind)
- वायरस/स्पैम सुरक्षा के साथ ईमेल सेवाएँ और वेबमेल (POP/IMAP/SMTP, ClamAV, SpamAssassin, Sieve, Roundcube)
- MariaDB/MySQL और PostgreSQL डेटाबेस
- Let's Encrypt SSL समर्थन
- ब्रूट-फोर्स सुरक्षा और IP प्रबंधन के साथ फ़ायरवॉल (iptables, fail2ban, ipset)

## समर्थित सिस्टम

- **MSVSphere:** 9
- **AlmaLinux:** 9
- **RockyLinux:** 9

**ध्यान दें:**

- HestiaCP 32-बिट ऑपरेटिंग सिस्टम को समर्थन नहीं करता!
- OpenVZ 7 या पुराने संस्करणों पर HestiaCP का उपयोग करते समय DNS/फ़ायरवॉल समस्याएँ हो सकती हैं। KVM/LXC आधारित वर्चुअलाइजेशन विकल्पों की सिफारिश की जाती है।

## Hestia कंट्रोल पैनल इंस्टॉल करें

- **नोट:** पूर्ण कार्यक्षमता सुनिश्चित करने के लिए कृपया एक ताज़ा सर्वर इंस्टॉलेशन पर इंस्टॉल करें।

हालांकि हम इंस्टॉलेशन प्रक्रिया को सरल बनाने का प्रयास करते हैं, लेकिन उपयोगकर्ताओं को लिनक्स सर्वर प्रबंधन का बुनियादी ज्ञान होना आवश्यक है।

### चरण 1: लॉगिन

**root** या सुपरयूजर एक्सेस के साथ SSH के माध्यम से लॉगिन करें:

```bash
ssh root@your.server
```

### चरण 2: डाउनलोड करें

नवीनतम इंस्टॉल स्क्रिप्ट प्राप्त करें:

```bash
wget https://dev.brepo.ru/bayrepo/hestiacp/raw/branch/master/install/hst-install.sh
```

### चरण 3: निष्पादित करें

स्क्रिप्ट चलाएँ और स्क्रीन निर्देशों का पालन करें:

```bash
bash hst-install.sh
```

इंस्टॉलेशन पूरा होने पर, आपको एक स्वागत ईमेल (यदि कॉन्फ़िगर किया गया हो) और लॉगिन विवरण प्राप्त होंगे।

### कस्टम इंस्टॉलेशन

घटकों को चुनने के लिए पैरामीटर का उपयोग करें, विकल्प देखें:

```bash
bash hst-install.sh -h
```

## मौजूदा इंस्टॉलेशन अपडेट करें

स्वचालित अपडेट डिफ़ॉल्ट रूप से सक्षम हैं (**सर्वर सेटिंग्स > अपडेट** के माध्यम से प्रबंधित)। मैन्युअल अपडेट:

```bash
dnf update
```

## समस्याएँ और सहायता

- RPM संस्करण से संबंधित मुद्दे: [GitHub इश्यू दर्ज करें](https://github.com/bayrepo/hestiacp-rpm/issues)
- मूल Debian/Ubuntu संस्करण: [मूल प्रोजेक्ट रिपॉजिटरी](https://github.com/hestiacp/hestiacp)

## कॉपीराइट

मूल कॉपीराइट [HestiaCP](https://github.com/hestiacp/hestiacp) के पास है

## लाइसेंस

हेस्टिया कंट्रोल पैनल [GPL v3](https://github.com/hestiacp/hestiacp/blob/release/LICENSE) लाइसेंस के तहत जारी किया गया है, और [VestaCP](https://vestacp.com/) पर आधारित है।
