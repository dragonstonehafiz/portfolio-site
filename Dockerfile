FROM python:3.9-slim
EXPOSE 8080
WORKDIR /app
COPY . ./
RUN pip install -r requirements.txt
ENTRYPOINT ["streamlit", "run", "1_🏠︎_HomePage.py", "--server.port=8080"]