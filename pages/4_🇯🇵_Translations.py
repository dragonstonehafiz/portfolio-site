import streamlit as st
import utils.ProjData_Translate as ProjectData
from utils.StreamlitFormat import create_page_elements

st.set_page_config(
    page_title="Japanese Fan Translations",
    page_icon="🇯🇵"
)
st.title("Japanese Translation Projects")

st.header("Introduction")
st.markdown(
    """
    This section is where I share some **fan translation projects**, mainly focused on **Japanese drama CDs**. These are unofficial translations I’ve worked on as a way to practice and improve my skills, while also making the content more accessible to others who might be interested.

    For each project, I’ve added:
    - **Subtitles synced to the original audio** for better readability.
    - **Dialogue translations** that try to keep the original tone and character personality.
    - **Small cultural notes** where needed to help things make sense.

    I also use tools like:
    - **AI transcription (OpenAI Whisper)** to assist with difficult-to-hear lines.
    - **A small translation helper app** I built to test different phrasing options.

    These are just personal projects, so they’re not perfect, but I hope they’re helpful to anyone who enjoys this kind of content!
    """
    )

projects = {
    'Too Many Losing Heroines!!! Drama CD Vol. 1 Story 1': ProjectData.makeine_vol1ep1,
    'Too Many Losing Heroines!!! Drama CD Vol. 1 Story 2': ProjectData.makeine_vol1ep2,
    'Nichijou Daily Calendar CD Vol. 1: "April"': ProjectData.nichijou_himekuri_vol1_4
}

st.header("Projects")

create_page_elements(projects, "translations")

