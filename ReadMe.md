# Ovara Configs - Config Editor System

This repository provides a configurable system designed to manage and edit server configurations with ease. It includes a user-friendly interface for modifying settings dynamically and demonstrates the usage through a sample configuration file.

## About the Project

The Config Editor System by [Ovara Service](https://shop.ovara.gg) is a comprehensive tool for managing server configurations in FiveM. It allows server administrators to:
- **Easily access and edit configurations** through a graphical user interface (GUI).
- **Handle configurations dynamically**, ensuring changes are immediately reflected without restarting the server.
- **Use current coordinates**, allowing admins to insert their in-game position directly into location-based settings.
- **Teleport to coordinates**, enabling quick navigation to specified locations within the config.
- **Provide examples** for how to implement the system with `sh_bansystem_config.lua` as a template.

## Key Features

- **Dynamic Configuration Management**: Load, edit, and save configurations seamlessly.
- **User Interface**: An intuitive editor built with HTML, CSS, and JavaScript to allow real-time configuration changes.
- **Coordinate Integration**: Insert your current in-game coordinates into config fields with a single click.
- **Teleportation**: Teleport to any location defined in the config for easy testing and verification.
- **Integration with FiveM**: Optimized for server-side and client-side synchronization, ensuring consistency across all users.
- **Database Support**: Stores configurations securely using MySQL.

![Screenshot of Config Editor](https://www.floba-media.de/wp-content/uploads/2025/03/Ovara_ConfigEditor_v1.0.1.png)

## Getting Started

### Installation
1. Clone or download the repository to your FiveM resource folder.
2. Ensure that your MySQL database is set up and accessible by the server.
3. Add the resource to your `server.cfg`:
   ```
   ensure ov_configs
   ```

### Usage
1. Start the FiveM server and load the resource.
2. Use the command `/openConfig <name>` in-game to access the Config Editor for a specific configuration.
3. Modify the configuration values using the GUI and click **Save** to apply changes.
4. Changes will be updated in the database and immediately applied to the server.

### Example Configuration
The sample file `sh_bansystem_config.lua` serves as a template to demonstrate how configurations should be structured and integrated. It can be adapted to suit your specific needs.

## Requirements
- **[oxmysql](https://github.com/overextended/oxmysql)**: MySQL script to store configuration data

## Contributions
Contributions are welcome! Feel free to submit pull requests or report issues to improve the system.

## License
This project is licensed under the MIT License.
