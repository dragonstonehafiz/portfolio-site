import streamlit as st
from utils.StreamlitFormat import connect_with_me

st.set_page_config(
    page_title="Muhd Hafiz's Portfolio Site",
    page_icon="🏠"
)
st.title("Muhd Hafiz's Portfolio Site")

connect_with_me()

st.header("About")
st.markdown(
    """
    I am an undergraduate at the **Singapore Institute of Technology**, majoring in **Applied Artificial Intelligence**. 
    Previously, I studied **Game Development and Technology** at **Nanyang Polytechnic**, where I gained experience in **game programming and software development**.

    I primarily work with **C++ and Python**, applying them to projects in **game development, machine learning, and automation**. 
    My interests include **AI-driven applications, system automation, and optimization**, and I often build tools to **enhance workflows or experiment with new technologies**.

    Beyond programming, I have an interest in **Japanese media**, particularly **anime drama CDs**, which led me to **transcribing and translating content** as a personal project. This site serves as a collection of my work, documenting both academic and personal projects.

    """
    )
st.divider()

st.header("Skills")
st.markdown(
    """
    ### **Programming Languages**
    - **C++** (Primary)  
    - Python  
    - C#  
    - Java  
    - R  

    ### **Game Development**
    - **Engines:** Unity, LibGDX  
    - **AI Systems:** Pathfinding (A*), Finite State Machines, Procedural Generation  
    - **Physics & Mechanics:** Collision detection, game loops, event handling  

    ### **Machine Learning & AI**
    - **Frameworks:** PyTorch, Transformers (Hugging Face)  
    - **Projects:** Image upscaling, sentiment analysis, AI-driven transcription  

    ### **Automation & Tools**
    - **APIs:** YouTube Data API, OpenAI Whisper & GPT-4o  
    - **Scripting & Workflow Tools:** Spreadsheet automation, data processing  

    ### **Software & Other Tools**
    - **IDEs:** VSCode, Visual Studio, PyCharm, IntelliJ IDEA  
    - **Adobe Tools:** Premiere Pro, Photoshop  
    """
)
st.divider()
