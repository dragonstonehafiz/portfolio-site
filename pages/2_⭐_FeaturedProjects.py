import streamlit as st
import utils.ProjData_Normal as ProjData_Normal
import utils.ProjData_Translate as ProjData_Translate
from utils.StreamlitFormat import create_page_elements


st.set_page_config(
    page_title="Featured Projects",
    page_icon="⭐"
)

featured_projects = {
    "Translator Helper": ProjData_Normal.TranslatorHelper,
    "Too Many Losing Heroines!!! Drama CD Vol. 1 Story 2": ProjData_Translate.makeine_vol1ep2,
    "Anime Image Upscaler": ProjData_Normal.ESRGAN_M,
    "Electronica": ProjData_Normal.Electronica
}
st.title("Featured Projects")

create_page_elements(featured_projects, "Featured")