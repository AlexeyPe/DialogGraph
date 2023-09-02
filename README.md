# DialogGraph
Addon for Godot 3.5, graph for creating a dialog system from nodes

**⚠ The addon is in a beta version at the development stage, it can be used, but without guarantees of reliability (there are enough bugs)**
**⚠ Work on the addon has stopped, but will be continued in the distant future (I will continue?). I plan to write a big addon for data, it will be similar to structures and tables in ue4/ue5, maybe this addon will become part of a future addon**

### Preview Images

<img src="https://github.com/AlexeyPe/DialogGraph/assets/70694988/da6690a9-e2eb-4ca0-a29e-1216cc77f54c" width="500" />
<img src="https://github.com/AlexeyPe/DialogGraph/assets/70694988/5dc40e25-78be-4f3c-8446-f97842babdf7" width="500" />
<img src="https://github.com/AlexeyPe/DialogGraph/assets/70694988/4c042cfd-07b1-474b-ae7b-5be512a4e314"/>

### Nodes

Node | Description
--- | ---
TimelineHeadNode | The main node from which any story begins, you can create any number of such nodes
DialogueNode | Speaker - the name of the character who says what the text of the next (below) field. You can add an option to branch the plot. (the Speaker field can be empty)
CommentNode | You can take notes in this node, it does not affect the plot
SetNode | Used in visual programming,, a large list of operations is supported: =, +=, -=, *=, /=, %=, abs, inverting(for bool)
IfNode | Used in visual programming, you can compare a variable from the list of variables or a variant with a random one, as well as compare with a constant
MatchNode | Used in visual programming, works like if, but you can create many cases (works like in gdscript)
SignalNode | Emit 1 signal in DialogueManager, the argument passes signal name and signal data. signal name is a variable from the list, you can create it
SignalNodePreviewTexture | This is a SignalNode, but with a preview to fill in signal data
SignalNodePreviewSound | This is a SignalNode, but with a preview to fill in signal data

⚠ If Node has operations by type =Variable and so on, they are there, but they are not done, they are just added to the list, this is a plan for the future, then they should work

### Variables

Variable | Description
--- | ---
int | GDScript int, SpinBox in increments of 1, changing the value when scrolling the mouse wheel
float | GDScript float, SpinBox in increments of 0.01, changing the value when scrolling the mouse wheel
string | GDScript string, LineEdit
bool | GDScript bool, CheckBox
signal | GDScript string, LineEdit. This variable is used for SignalNode, it is passed as the SignalName argument

### Where to use this addon?
1. For visual novels, you can write a simple novel with ramifications or a more complex one with health and randomness (IfNode and random)
<img src="https://github.com/AlexeyPe/DialogGraph/assets/70694988/7438346c-e3b1-4ace-9dbc-4842a672b449"/>

2. Dialogues in games like undertail, skyrim and many others
<img src="https://github.com/AlexeyPe/DialogGraph/assets/70694988/c02d3a1e-566b-4e17-ac36-d204b05f59a4" width="500"/>
<img src="https://github.com/AlexeyPe/DialogGraph/assets/70694988/80a80527-55a9-44ee-ad90-b4cc42cf0122" width="500"/>

3. In theory, you can use this addon for tutorials, because tutorials display text in a dialog box, with this addon you can easily make forward and backward buttons, as well as the ability to close the window and everything else
![Screenshot_2015-06-17-17-29-00](https://github.com/AlexeyPe/DialogGraph/assets/70694988/66640af0-86df-44e9-825c-883ca7742cf1)

### DialogueManagerBox
You can create a custom dialog box, put this scene in your scene and provide links.

You can also write your own implementation (for example, if you need more than 4 buttons), to do this, process signals from the DialogueManager

**Initially only 4 button links, because before the dialog node supported only 4 buttons, now there can be as many as you like

Thanks to this approach, you can make the UI whatever you want and quickly add an addon where you already have a UI, but you would just like to add a dialog editor

![Godot_v3 5 2-stable_win64_oooN5NdmzX](https://github.com/AlexeyPe/DialogGraph/assets/70694988/d5f2af36-1504-4ccb-ba10-c238ac4dfc2a)

My telegram [@Alexey_Pe](https://t.me/Alexey_Pe)

I do not know English, this was translated by a translator, if you have any recommendations - write to me
