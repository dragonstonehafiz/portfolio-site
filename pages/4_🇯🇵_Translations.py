import streamlit as st
from utils.ProjectLoader import load_page_projects
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

    I also use tools like:
    - **AI transcription (OpenAI Whisper)** to assist with difficult-to-hear lines.
    - **A small translation helper app** I built to test different phrasing options.

    These are just personal projects, so they’re not perfect, but I hope they’re helpful to anyone who enjoys this kind of content!
    """
    )

# Load featured projects from page configuration
featured_projects = load_page_projects("translations")

st.header("Projects")

create_page_elements(featured_projects, "translations")

