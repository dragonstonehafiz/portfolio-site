import streamlit as st
import utils.ProjData_Translate as ProjectData
from utils.StreamlitFormat import *

projects = {
    'Too Many Losing Heroines!!! Drama CD Vol. 1 Story 1': ProjectData.makeine_vol1ep1,
    'Too Many Losing Heroines!!! Drama CD Vol. 1 Story 2': ProjectData.makeine_vol1ep2
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

st.title("Projects")

# Get unique tags and project types
unique_tags = get_unique_tags(projects.values())
unique_types = get_unique_project_types(projects.values())

st.sidebar.header("Filters")
sort_order = st.sidebar.radio("Sort projects by date", ["Ascending", "Descending"], index=1)
selected_tags = st.sidebar.multiselect("Filter by Tags", unique_tags)
selected_type = st.sidebar.selectbox("Filter by Project Type", ["All"] + unique_types)

# Process projects: filter and sort
filtered_projects = filter_projects(projects.values(), selected_tags, selected_type)
sorted_projects = sort_projects(filtered_projects, sort_order)
reverse_sort = sort_order == "Descending"
filtered_projects = create_sorted_list(projects, selected_tags, selected_type, reverse_sort)

# Links
render_and_nav(filtered_projects)

# Sidebar Filters
connect_with_me()

