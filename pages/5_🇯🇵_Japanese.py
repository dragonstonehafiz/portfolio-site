import streamlit as st
import utils.ProjData_Translate as ProjectData
from utils.ProjectFunctions import CreateTagList, CreateSidebar, CreateSortedList, RenderAndNavigation

projects = {
    'Too Many Losing Heroines!!! Drama CD Vol. 1 Story 1': ProjectData.makeine_vol1ep1
}

st.set_page_config(
    page_title="Japanese Fan Translations",
    page_icon="🇯🇵"
)
st.title("Japanese Translation Projects")

st.header("自己紹介")
st.markdown(
    """
    2022年から日本語を勉強始めました。理由は特になかったが強いて言えばきっとその時の自分は余計に暇だったからです。
    
    始まるきっかけはアニソンでした。僕はアニメには興味はなかったんです。でもある日はネットでいい評判されたアニメが耳に入ったんです。あのアニメは「ぼっち・ざ・ろっく！」。いい作品でした。特にアニメに出た曲です。一番好きな曲は「何が悪い」でした。あの時、理解出来なかったけど、本当に好きでした。
    
    数か月後、僕はこう思いました。「その曲は何の意味でしょうか」と。その一環で日本語の道を歩き始めました。そしてもっと上手くなるように、アニメをよく見ることになりました。正直、こんなに好きになるのは思わなかったんです。ちなみに僕の一番好きなアニメは「氷菓」です（いつか第2期がくるかな？）。
    
    えっと…どうやって終えようか分からないのでこれでおしまい。読んでくれてありがとうございました。   
    """
    )

all_tags = CreateTagList(projects)
reverse_sort, selected_tags = CreateSidebar(all_tags)
sorted_dict = CreateSortedList(projects, selected_tags, reverse_sort)
RenderAndNavigation(sorted_dict)

