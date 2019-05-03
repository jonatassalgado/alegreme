### Requisitos
- Anaconda
- Rails 5
- Node
- Yarn
- Scrapy
- Splash
- Flask


### Rails
rails s


### Anaconda
conda create --name alegreme python=3
source activate alegreme


### Scrapy
sudo docker run -p 8050:8050 -p 5023:5023 scrapinghub/splash
scrapy crawl event -s CLOSESPIDER_ITEMCOUNT=25


### Flask
python ml/api/main.py
