# LinuxKernel_buildHelper
a small script to help automate the building of the linux kernel so you don't have to remember stuff.

Ensure you can compile and install a fresh kernel with your desired patches applied every time.

<b>Important Instructions</b>
<ol>
<li>Your first time running, you will want to install requirements and download the kernel. Run the script, and enter yes to these prompts.</li>
<li>First time running you will want to enter "yes" for copying your kernel's config file.</li>
<li>You should also review the patches folder. These will be automatically applied to the kernel. They aren't required, and you can safely empty that folder.</li>
<li>Patches that are made obsolete via upstream changes to the kernel can be ignored or archived via the script.</li>
<li>Installation requires super user access; but compileation does not.</li>
</ol>

Space requreiments:
This software clones the entire linux kernel using git, then makes a copy of that repo on your local system. So you need enough space for two kernels.

Notes: This script can be greatly improved. I may one day integrate it with my ISO generation code and integrate live USB flashing.
