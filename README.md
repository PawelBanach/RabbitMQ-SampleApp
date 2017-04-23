# RabbitMQ-SampleApp
RabbitMQ sample app for Distributed Systems

## Architecture

![alt text](https://github.com/PawelBanach/RabbitMQ-SampleApp/blob/master/RabbitMQ-simple_hospital_architecture.jpg "Architecture")

## Example usage

Technician:
```bash
ruby -rubygems technician.rb knee ankle
ruby -rubygems technician.rb knee elbow
```

Admin:
```bash
ruby -rubygems admin.rb
```

Doctor:
```bash
ruby -rubygems doctor.rb Smith elbow
ruby -rubygems doctor.rb Mercedes knee
ruby -rubygems doctor.rb Gates ankle
```
