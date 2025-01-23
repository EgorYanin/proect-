import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns

data = pd.read_csv('Food_Time_Data_Set.csv')

print(data.info())
print(data.head())

missing_values = data.isnull().sum()
print("\nПропуски в данных:")
print(missing_values)

threshold = 0.5 * len(data.columns)
data = data.dropna(thresh=threshold)

numeric_columns = data.select_dtypes(include=['float64', 'int64']).columns
data[numeric_columns] = data[numeric_columns].fillna(data[numeric_columns].mean())

print("\nКоличество дубликатов:", data.duplicated().sum())
data = data.drop_duplicates()

if 'date_column' in data.columns:
    data['date_column'] = pd.to_datetime(data['date_column'], errors='coerce')

for column in numeric_columns:
    if data[column].notnull().sum() > 0:
        plt.figure(figsize=(10, 4))
        sns.boxplot(x=data[column])
        plt.title(f"Аномалии в {column}")
        plt.show()
    else:
        print(f"Столбец {column} пустой или содержит только NaN.")


for column in numeric_columns:
    Q1 = data[column].quantile(0.25)
    Q3 = data[column].quantile(0.75)
    IQR = Q3 - Q1
    lower_bound = Q1 - 1.5 * IQR
    upper_bound = Q3 + 1.5 * IQR
    data = data[(data[column] >= lower_bound) & (data[column] <= upper_bound)]

if 'author_id' in data.columns and 'post_id' in data.columns:
    authors = data[['author_id', 'author_name']].drop_duplicates()
    posts = data.drop(columns=['author_name']).copy()

    print("\nТаблица авторов:")
    print(authors.head())

    print("\nТаблица постов:")
    print(posts.head())

if 'post_content' in data.columns and 'likes' in data.columns:
    data['post_length'] = data['post_content'].apply(len)
    sns.scatterplot(x=data['post_length'], y=data['likes'])
    plt.title("Влияние длины поста на количество лайков")
    plt.show()

data.to_csv('cleaned_data.csv', index=False)
print("\nОбработанные данные сохранены в файл cleaned_data.csv")


