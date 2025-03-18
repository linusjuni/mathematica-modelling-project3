from data_loader import DataLoader
import data_visualisation

loader = DataLoader()

channel_coordinates = loader.load_to_np('channel_data.txt')

channel_distances = loader.calculate_points_distance(channel_coordinates)

latitudes = channel_distances['latitudes']
longitudes = channel_distances['longitudes']
heights = channel_distances['heights']
distances = channel_distances['distances']
cumulative_distances = channel_distances['cumulative_distances']

print(distances)
