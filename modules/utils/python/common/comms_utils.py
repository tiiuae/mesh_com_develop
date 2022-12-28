import subprocess

class comms_utils:
    def __init__(self):
        self.debug = false

    def subprocess_exec(arg):
        proc = subprocess.Popen(arg, stdout=subprocess.PIPE,
                                shell=False)
        return proc.communicate()[0]

    def subprocess_nested_exec(arg1, arg2):
        proc = subprocess.Popen(arg1, stdout=subprocess.PIPE,
                                shell=False)
        proc_nested = subprocess.Popen(arg2, stdin=proc.stdout,
                                       stdout=subprocess.PIPE, shell=False)
        proc.stdout.close()
        return proc_nested.communicate()[0]
