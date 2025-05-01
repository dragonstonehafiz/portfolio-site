from utils.ProjectObject import ProjectObject
from datetime import date

AI_Game = ProjectObject(
    title="AI Pathfinding Game",
    description="A **turn-based** game I made for one of my AI modules. The game was written on a custom engine provided by the school, and the code was written in `C++`.",
    date_=date(year=2019, month=1, day=6),
    vid_link="https://youtu.be/5544wAwSE1I",
    what_i_did=[
        "Implemented **A-Star and BFS pathfinding algorithms**, enabling AI-controlled units to navigate complex environments efficiently.",
        "Designed a **Finite State Machine (FSM) for AI behavior**, allowing dynamic transitions between patrol, chase, and attack states.",
        "Developed a **fog-of-war vision system**, restricting player visibility and enhancing tactical gameplay.",
        "Created a **procedural maze generator**, ensuring randomized level layouts for increased replayability.",
        "Integrated the **IrrKlang library** for dynamic sound handling, improving immersion with responsive audio effects."],
    img_paths=[
        "images/games/aigame1.png",
        "images/games/aigame2.png",
        "images/games/aigame3.png",
        "images/games/aigame4.png"],
    tags=["c++", "games", "nyp"])

Physics_Game = ProjectObject(
    title="Simple Physics Game",
    description="A **Peggle inspired game** made during my Physics for Game Programming module. The game was written in `C++` on a custom game engine provided by the school.",
    date_=date(year=2017, month=6, day=4),
    vid_link="https://youtu.be/jAr9eGcGQJk",
    what_i_did=[
        "Developed **a physics simulation system** handling gravity and impulse forces, improving gameplay realism.",
        "Implemented **custom vector-based collision detection**, enabling efficient and precise object interactions.",
        "Integrated the **IrrKlang library for dynamic sound management**, enhancing game immersion with responsive audio effects."],
    img_paths=[
        "images/games/physicsgame1.png",
        "images/games/physicsgame2.png",
        "images/games/physicsgame3.png",
        "images/games/physicsgame4.png"],
    tags=["c++", "games", "nyp"])

Last_Survivor = ProjectObject(
    title="The Last Survivor",
    description="""
    A wave-based top-down shooter developed in Unity. 
    The game features multiple enemy types with AI-driven movement and attack behaviors, requiring players to adapt their strategies as waves progress.
    """,
    date_=date(year=2019, month=3, day=1),
    vid_link="https://youtu.be/aMmrSXN9EI8",
    what_i_did=[
        "Developed **wave-based progression** and **enemy spawning mechanics** in Unity (C#), ensuring a scalable and balanced gameplay loop.",
        "Implemented **AI pathfinding** and enemy behaviors without using Unity’s NavMesh, enhancing combat dynamics and player engagement.",
        "Designed and **programmed four distinct NPC** types, including melee, ranged, boss, and turret units, creating diverse strategic encounters."],
    img_paths=[
        "images/games/thelastsurvivor1.png",
        "images/games/thelastsurvivor2.png",
        "images/games/thelastsurvivor3.png",
        "images/games/thelastsurvivor4.png"],
    tags=["c#", "games", "nyp", "unity"])

Electronica = ProjectObject(
    title="Electronica",
    description="A **top down shooter** inspired by Geometry Wars. Built on the `Unity Game Engine`, all the code for this game was written by me over the course of three months. This was a solo project, and the final thing I worked on before graduating from Nanyang Polytechnic.",
    date_=date(year=2020, month=2, day=10),
    vid_link="https://youtu.be/MX7wlNfxtfw",
    what_i_did=["Designed and implemented **five unique enemy AI behaviors** in Unity (C#), enhancing gameplay variety and difficulty scaling.",
                "Developed **four dynamic boss encounters** with unique mechanics and multi-phase battles to challenge players.",
                "Created **two distinct game modes**, Classic and Onslaught, increasing replayability and gameplay diversity.",
                "Designed and **animated interactive UI elements**, including dynamic health bars for both players and bosses, improving visual clarity."],
    img_paths=["images/games/electronica1.png",
               "images/games/electronica2.png",
               "images/games/electronica3.png",
               "images/games/electronica4.png",
               "images/games/electronica5.png",
               "images/games/electronica6.png"],
    tags=["c#", "games", "nyp", "unity"])

Locus = ProjectObject(
    title="L.O.C.U.S",
    description="""
    A virtual reality horror puzzle game designed for the `HTC Vive`. 
    The game features motion-based interactions, environmental puzzles, and scripted horror events, creating an immersive first-person experience.
    """,
    date_=date(year=2019, month=8, day=21),
    vid_link="https://youtu.be/nvTEuyOUynI",
    what_i_did=["Developed **VR controller input handling** for HTC Vive in Unity (C#), ensuring intuitive and immersive interactions for players.", 
                "**Implemented core gameplay mechanics**, including puzzles, scripted scares, and game progression, enhancing the horror-puzzle experience."],
    img_paths=["images/games/locus1.png", "images/games/locus2.png"],
    tags=["c#", "games", "nyp", "unity", 'vr'])

ResourceManagementGame = ProjectObject(
    title="Resource Management Game",
    description="""
    A real-time resource management simulation developed in `Java` using `LibGDX`. 
    """,
    date_=date(year=2024, month=2, day=23),
    vid_link="https://youtu.be/xTgrENeVFi4?si=33A5JgegELn4uFcM",
    what_i_did=[
        "Developed **object-oriented game object classes** in Java using LibGDX, providing a structured foundation for game mechanics.",
        "Implemented **core game scenes**, handling scene transitions and UI rendering to improve game flow and user experience."],
    img_paths=[
        "images/sit/oop-game1.png",
        "images/sit/oop-game2.png",
        "images/sit/oop-game3.png",
        "images/sit/oop-game4.png"],
    tags=["java", "games", "sit", "libgdx"])

ESRGAN_M = ProjectObject(
    title="Anime Image Upscaler",
    description="""
    An image upscaler built using ESRGAN, fine-tuned for anime-style images at 256x256 resolution. 
    The model was trained on a dataset of over 15,000 images to reduce artifacts and enhance detail, making it more effective for upscaling low-resolution anime artwork.
    """,
    date_=date(year=2024, month=11, day=29),
    vid_link="https://youtu.be/zZiL5X7dj4A?si=lbiVmPAo993uzuzh",
    github_link="https://github.com/dragonstonehafiz/aai3001-large-project",
    what_i_did=[
        "**Curated a dataset of over 15,000 images** to finetune ESRGAN for anime-style image upscaling, improving model accuracy and visual quality.",
        "Implemented and **optimized ESRGAN finetuning for enhanced anime image upscaling**, adjusting hyperparameters and training pipelines.",
        "Developed an **interactive Streamlit-based UI** for real-time image upscaling, making the model accessible to users."],
    img_paths=[
        "images/sit/aai3001_1_lowres.png",
        "images/sit/aai3001_1_upscale.png",
        "images/sit/aai3001_2_lowres.png",
        "images/sit/aai3001_2_upscale.png",
        "images/sit/aai3001_3_lowres.png",
        "images/sit/aai3001_3_upscale.png"],
    tags=["python", "ai", "streamlit", "sit", "anime"])


TranslatorHelper = ProjectObject(
    title="Translator Helper",
    description="""
    A little hobby of mine is **transcribing and translating anime drama CDs**. 
    While I am generally able to do so on my own with some difficulty, there are times where I am unable to figure out what a character is saying, or how exactly I should translate a particular phrase.
    
    As such, I quickly put together an app to help me with the process.
    """,
    github_link="https://github.com/dragonstonehafiz/translator-helper",
    date_=date(year=2025, month=3, day=9),
    last_update=date(year=2025, month=4, day=14),
    what_i_did=[
        "Added support for **audio transcription** via OpenAI Whisper using file upload or microphone input.",
        "Enabled **subtitle file parsing** (`.srt`, `.ass`) to extract scene metadata like character names and tone.",
        "Integrated **web context retrieval** with Tavily + LangChain to enrich translation inputs.",
        "Implemented **context-aware translation** outputs: natural, literal, and annotated.",
        "Created a **grading system** to evaluate translation quality across fluency, accuracy, and cultural fit."
    ],
    img_paths=[
        "images/other/translatorHelper_context2.png",
        "images/other/translatorHelper_translate.png",
        "images/other/translatorHelper_grade.png",
        "images/other/translatorHelper_transcribe.png"
    ],
    vid_link="https://youtu.be/Zi3OjbpptQk",
    tags=["python", "api", "ai", "anime", "streamlit", "langchain"])

BirdLaserTargeter = ProjectObject(
    title="Bird Laser Targeter on the Edge",
    description="""
    A Raspberry Pi Zero 2W-powered system designed to **detect birds and deter them using a laser pointer**.  
    The project integrates servo motors, a laser diode, a camera, and microphone-based audio triggers.  
    It features a **state-machine-based control system** and supports **both local and remote detection** via MQTT.

    While the model training and YOLOv5 implementation were handled by teammates,  
    I was responsible for **system integration, hardware interfacing**, and **overall architecture**.
    """,
    date_=date(year=2025, month=3, day=29),
    github_link="https://github.com/dragonstonehafiz/inf2009-project",
    what_i_did=[
        "Implemented **real-time MQTT communication** between the Pi Zero and a remote server, enabling offloaded bird detection and reducing device-side processing load by over 80%.",
        "Coordinated and deployed the **full software-hardware stack**, integrating audio triggers, camera input, laser targeting, and servo motion to deliver an autonomous bird deterrence system."
    ],
    img_paths=[
        "images/sit/inf2009_project1.png",
        "images/sit/inf2009_project2.png"
    ],
    vid_link="https://www.youtube.com/watch?v=NGxBpvvaONQ",
    tags=["python", "ai", "sit"]
)

SpendingDashboard = ProjectObject(
    title="Spending Dashboard",
    description="""
    A Streamlit-based dashboard designed to **track, visualize, and analyze personal spending data**.  
    The project reads purchase records from a structured `.xlsx` file, supports **interactive filtering**, and generates **dynamic financial insights** through a clean UI.

    It features **custom Plotly charts**, an **Excel auto-formatting pipeline** with conditional category styling, and robust search functionality with flexible cost, date, and category filters.
    """,
    date_=date(year=2025, month=4, day=28), 
    github_link="https://github.com/dragonstonehafiz/budgeting-analysis",
    what_i_did=[
        "Built a full Streamlit application with multiple data exploration modes (full dataset, yearly focus, advanced search), improving usability.",
        "Designed and implemented an Excel formatting pipeline that standardized data entry, reduced user errors, and accelerated spreadsheet preparation using openpyxl.",
        "Developed a suite of interactive visualizations (line, bar, pie, scatter) with custom color schemes, enhancing trend discovery and financial insight generation.",
    ],
    img_paths=[
        "images/other/budgeting1.png",
        "images/other/budgeting2.png",
        "images/other/budgeting3.png",
        "images/other/budgeting4.png",
        "images/other/budgeting5.png",
    ],
    tags=["python", "streamlit"]
)

