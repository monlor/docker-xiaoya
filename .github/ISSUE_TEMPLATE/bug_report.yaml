name: Bug 报告
about: 创建一个报告来帮助我们改进，不使用模板的问题将直接被关闭
title: "[Bug]: "
labels: ["bug"]
assignees: 
  - monlor

body:
  - type: markdown
    attributes:
      value: |
        💡 感谢反馈问题，花一点时间补充下面的信息，方便我解决问题。
  - type: checkboxes
    id: checklist
    attributes:
      label: 提交检查
      description: 请确认以下内容
      options:
        - label: 我已经搜索过相关Issue，没有找到类似问题
        - label: 我已经检查过当前页面底部的常见问题列表，没有找到类似问题 
        - label: 我已经检查过[问题清单](https://github.com/monlor/docker-xiaoya/blob/main/Questions.md)，没有找到类似问题
    validations:
      required: true

  - type: textarea
    id: description
    attributes:
      label: 描述 bug
      description: 对 bug 的清晰简洁的描述。
    validations:
      required: true

  - type: textarea
    id: reproduction
    attributes:
      label: 重现步骤
      description: 复现问题的步骤:
        1. 进入 '...'
        2. 点击 '....'
        3. 滚动到 '....'
        4. 出现错误
    validations:
      required: true

  - type: textarea
    id: expected
    attributes:
      label: 预期行为
      description: 对您期望发生的行为的清晰简洁的描述。
    validations:
      required: false

  - type: textarea
    id: screenshot
    attributes:
      label: 截图
      description: 如果适用,添加截图以帮助解释您的问题。

  - type: dropdown
    id: device
    attributes:
      label: 设备 (请填写以下信息)
      options:
        - Linux
        - Windows
        - Mac
        - 群晖
        - 绿联
        - 其他（在其他信息中补充）
    validations:
      required: true

  - type: textarea
    id: additional
    attributes:
      label: 其他信息
      description: 在此添加有关问题的任何其他上下文。

