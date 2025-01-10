# Config Editor System

This repository provides a configurable system designed to manage and edit server configurations with ease. It includes a user-friendly interface for modifying settings dynamically and demonstrates the usage through a sample configuration file.

## About the Project

The Config Editor System is a comprehensive tool for managing server configurations in FiveM. It allows server administrators to:
- **Easily access and edit configurations** through a graphical user interface (GUI).
- **Handle configurations dynamically**, ensuring changes are immediately reflected without restarting the server.
- **Provide examples** for how to implement the system with `sh_bansystem_config.lua` as a template.

## Key Features

- **Dynamic Configuration Management**: Load, edit, and save configurations seamlessly.
- **User Interface**: An intuitive editor built with HTML, CSS, and JavaScript to allow real-time configuration changes.
- **Integration with FiveM**: Optimized for server-side and client-side synchronization, ensuring consistency across all users.
- **Database Support**: Stores configurations securely using MySQL.

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
- **FiveM**: Latest version
- **MySQL**: To store configuration data
- **Node.js/NUI**: For rendering the graphical interface

## Contributions
Contributions are welcome! Feel free to submit pull requests or report issues to improve the system.

## License
This project is licensed under the MIT License.

