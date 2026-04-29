{ ... }:

{
  security.auditd.enable = true;
  security.audit.enable = true;

  security.audit.rules = [
    # sudo / privilege escalation
    "-w /usr/bin/sudo -p x -k sudo"

    # user management
    "-w /etc/passwd -p wa -k identity"
    "-w /etc/group -p wa -k identity"
    "-w /etc/shadow -p wa -k identity"

    # ssh config
    "-w /etc/ssh/sshd_config -p wa -k ssh"

    # execution tracking
    "-a always,exit -F arch=b64 -S execve -k exec"

    # chmod/chown
    "-a always,exit -F arch=b64 -S chmod,chown,fchmod,fchown -k perm_mod"
  ];
}
