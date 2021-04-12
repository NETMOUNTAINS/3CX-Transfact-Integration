# 3CX-Transfact-Integration
3CX Integration to Transfact Software (Transfact GmbH) using build-in CRM connector.


DONE:
-----
- CallJournaling: Send call details to TF after call ended
- ContactsLookup: Fetch caller details before call is initiated
- Basic Authentication (AccessKey + MandateID)
- Recodings Submission: Watcher with upload script

To-Do:
---------
- Nothing (for now)

Installation:
---------
### I. 3CX Template

1. Download .xml to a local folder of your choice
2. Open the 3CX admin panel
3. Make sure 3CX is licensed as "Pro" or "Enterprise" edition cause only this contain the needed CRM connector.
4. Navigate to Settings -> CRM Integration
5. Upload the previous downloaded file.
6. Fill in your data to the shown fields and save.

### II. Watcher script
1. Download .sh to /usr/bin at your 3CX-Instance
2. Make it executable (chmod +x)
3. Create service (see Example.service)
    a. Copy EXAMPLE.sh to /etc/systemd/system (e.g.: /etc/systemd/system/3cx-transfact.service)
    b. systemctl start 3cx-transfact
    c. systemctl enable 3cx-transfact
6. Reboot PBX.

Notes:
---------
- Nothing for now.

Compatibility:
---------
Tested with:
- 3CX (Professional/Enterprise) V16.0.6.641
- Transfact 19.045 (08/2020)

License & Contribution:
---------
The software published here is licensed under Creative-Commons License BY-ND. 

Thanks for contribution:
- K.Huynh, U.Hoffmann, H.Martin @ Transfact GmbH
