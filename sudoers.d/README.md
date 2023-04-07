### Enable sudo touch ID

In `/etc/pam.d/sudo`, prepend the following line:

```
auth       sufficient     pam_tid.so
```
