import Foundation

enum SampleMarkdown {
    static let project = """
    ---
    id: 550e8400-e29b-41d4-a716-446655440000
    color: "#4A90D9"
    archiveGroupBy: week
    ---

    # 工作任务

    ## Todo

    - [ ] 完成 API 设计 <!-- meta:{"id":"a1b2c3d4-e5f6-4711-8222-1234567890ab","created":"2024-03-15T10:00:00Z","tags":["紧急","重要"]} -->
      > 需要完成以下接口：
      > - `/api/users` GET / POST
      > - `/api/todos` CRUD
      >
      > 参考文档：**REST API 设计规范**
      >
      > ```json
      > { "status": 200, "data": [] }
      > ```

    - [ ] 写单元测试 <!-- meta:{"id":"d4e5f6a7-b8c9-4012-9333-abcdef123456","created":"2024-03-15T11:00:00Z"} -->

    - [ ] Code Review <!-- meta:{"id":"g7h8i9j0-k1l2-4321-9444-1234abcdef56","created":"2024-03-16T09:00:00Z","tags":["等待"]} -->

    ## Done

    - [x] ~~搭建项目框架~~ <!-- meta:{"id":"j0k1l2m3-n4o5-4987-9555-fedcba654321","created":"2024-03-10T09:00:00Z","done":"2024-03-12T14:30:00Z","tags":["重要"]} -->
      > 使用 SwiftUI 框架搭建
      > 包含基础路由和导航

    - [x] ~~配置 CI/CD~~ <!-- meta:{"id":"m3n4o5p6-q7r8-4567-9666-654321fedcba","created":"2024-03-08T08:00:00Z","done":"2024-03-09T16:00:00Z"} -->
    """
}
